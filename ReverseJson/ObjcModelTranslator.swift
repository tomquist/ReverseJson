import Foundation

public class ObjcModelCreator: ModelTranslator {
    
    public init() {}
    
    private let atomic = false
    private let readonly = true
    private let typePrefix = ""
    private var atomicyModifier: String {
        return (atomic ? "atomic" : "nonatomic")
    }
    
    public func translate(type: ModelParser.FieldType, name: String) -> String {
        let a = declarationsFor(type, name: name, valueToParse: "jsonValue")
        var ret = "#import <Foundation/Foundation.h>\n\n"
        ret += a.interfaces.joinWithSeparator("\n\n")
        ret += "\n\n"
        ret += a.implementations.joinWithSeparator("\n\n")
        return ret
    }
    
    public func isNullable(type: ModelParser.FieldType) -> Bool {
        switch type {
        case .Optional:
            return true
        default:
            return false
        }
    }
    
    public func hasPointerStar(type: ModelParser.FieldType) -> Bool {
        switch type {
        case .Number, .Unknown, .Optional(.Unknown):
            return false
        default:
            return true
        }
    }
    
    func memoryManagementModifier(type: ModelParser.FieldType) -> String {
        switch type {
        case .Optional(.Number), .Text:
            return "copy"
        case .Number:
            return "assign"
        default:
            return "strong"
        }
    }
    
    private func declarationsFor(type: ModelParser.FieldType, name: String, valueToParse: String) -> (interfaces: Set<String>, implementations: Set<String>, parseExpression: String, fieldRequiredTypeNames: Set<String>, fullTypeName: String) {
        switch type {
        case let .Enum(enumTypes):
            return ([], [], valueToParse, [], "id")
        case let .Object(fields):
            let className = name.camelCasedString
            let fieldValues = fields.map { field -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<String>, implementations: Set<String>) in
                let nullable = isNullable(field.type)
                
                let valueToParse = "dict[@\"\(field.name)\"]"
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName) = declarationsFor(field.type, name: className + field.name.camelCasedString, valueToParse: valueToParse)

                var modifiers = [atomicyModifier, memoryManagementModifier(field.type)]
                if (readonly) {
                    modifiers.append("readonly")
                }
                if nullable {
                    modifiers.append("nullable")
                }
                let modifierList = modifiers.joinWithSeparator(", ")
                let variableName = field.name.pascalCasedString
                let property = "@property (\(modifierList)) \(fieldFullTypeName) \(variableName);"
                let initialization = "_\(variableName) = \(parseExpression);"
                return (property, initialization, fieldRequiredTypeNames, fieldFullTypeName, subInterfaces, subImplementations)
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sort(<)
            let properties = fieldValues.sort{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.property}
            let initializations = fieldValues.sort{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.initialization.indent(3)}
            
            var interface = ""
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = forwardDeclarations.joinWithSeparator(", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            interface += [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dictionary;",
                "- (instancetype)initWithJsonValue:(id)jsonValue;\n",
            ].joinWithSeparator("\n")
            interface += properties.joinWithSeparator("\n")
            interface += "\n@end\nNS_ASSUME_NONNULL_END"
            
            var implementation = [
                "@implementation \(className)",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
                "    self = [super init];",
                "    if (self) {\n",
            ].joinWithSeparator("\n")
            implementation += initializations.joinWithSeparator("\n")
            implementation += "\n    }\n"
            implementation += "    return self;\n"
            implementation += "}\n"
            implementation += [
                "- (instancetype)initWithJsonValue:(id)jsonValue {",
                "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
                "        self = [self initWithJsonDictionary:jsonValue];",
                "    } else {",
                "        self = nil;",
                "    }",
                "    return self;",
                "}"
            ].joinWithSeparator("\n")
            implementation += "\n@end"
            
            let interfaces = fieldValues.lazy.map {$0.interfaces}.reduce(Set([interface])) { $0.union($1) }
            let implementations = fieldValues.lazy.map{$0.implementations}.reduce(Set([implementation])) { $0.union($1) }
            let parseExpression = "[[\(className) alloc] initWithJsonValue:\(valueToParse)]"
            return (interfaces, implementations, parseExpression, requiredTypeNames.union([className]), "\(className) *")
        case .Text:
            return ([], [], "[\(valueToParse) isKindOfClass:[NSString class]] ? \(valueToParse) : nil", [], "NSString *")
        case let .Number(numberType):
            let numberTypeMethod: String
            let typeName: String
            switch numberType {
            case .Bool:
                numberTypeMethod = "boolValue"
                typeName = "BOOL"
            case .Int:
                numberTypeMethod = "integerValue"
                typeName = "NSInteger"
            case .Float:
                numberTypeMethod = "floatValue"
                typeName = "float"
            case .Double:
                numberTypeMethod = "doubleValue"
                typeName = "double"
            }
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? [\(valueToParse) \(numberTypeMethod)] : 0", [], typeName)
        case var .List(listType):
            if case let .Number(numberType) = listType {
                listType = .Optional(.Number(numberType))
            }
            let listTypeValues = declarationsFor(listType, name: name, valueToParse: "item")
            let parseExpression = [
                "({",
                "    id value = \(valueToParse);",
                "    NSMutableArray *values = nil;",
                "    if ([value isKindOfClass:[NSArray class]]) {",
                "        NSArray *array = value;",
                "        values = [NSMutableArray arrayWithCapacity:array.count];",
                "        for (id item in array) {",
                "            id parsedItem = \(listTypeValues.parseExpression);",
                "            [values addObject:parsedItem ?: [NSNull null]];",
                "        }",
                "    }",
                "    [values copy];",
                "})"
            ].joinWithSeparator("\n")
            return (listTypeValues.interfaces, listTypeValues.implementations, parseExpression, listTypeValues.fieldRequiredTypeNames, "NSArray<\(listTypeValues.fullTypeName)> *")
        case .Optional(.Number):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? \(valueToParse) : nil", [], "NSNumber *")
        case .Optional(let optionalType):
            return declarationsFor(optionalType, name: name, valueToParse: valueToParse)
        case .Unknown:
            return ([], [], valueToParse, [], "id")
        }
    }
    
}

extension ModelParser.FieldType {
    private func toModel(name: String) -> String {
        let (typeName, decl) = self.makeSubtype("", subName: name, level: 0)
        if let decl = decl {
            return decl
        } else {
            return "typealias \(name) = \(typeName)\n"
        }
    }
    
    private func makeSubtype(name: String, subName: String, level: Int) -> (name: String, declaration: String?) {
        let fieldType: String
        let declaration: String?
        switch self {
        case let .Object(fields):
            fieldType = "\(subName.camelCasedString)"
            declaration = createStructDeclaration(fieldType, fields: fields, level: level)
        case let .Number(numberType):
            fieldType = numberType.rawValue
            declaration = nil
        case .Text:
            fieldType = "String"
            declaration = nil
        case let .List(listItemType):
            let (subTypeName, subDeclaration) = listItemType.makeSubtype("\(name)\(subName.camelCasedString)", subName: "\(subName)Item", level: level)
            declaration = subDeclaration
            fieldType = "[\(subTypeName)]"
        case let .Enum(enumTypes):
            fieldType = "\(subName.camelCasedString)"
            declaration = createEnumDeclaration(fieldType, cases: enumTypes, level: level)
        case let .Optional(type):
            let (subTypeName, subDeclaration) = type.makeSubtype(name, subName: subName, level: level)
            declaration = subDeclaration
            fieldType = "\(subTypeName)?"
        case .Unknown:
            fieldType = subName.camelCasedString
            declaration = "typealias \(fieldType) = Void".indent(level)
        }
        return (fieldType, declaration)
    }
    
    private func createStructDeclaration(name: String, fields: [ModelParser.ObjectField], level: Int = 0) -> String {
        var ret = "struct \(name) {\n".indent(level)
        let fieldsAndTypes = fields.map { f -> (field: String, type: String?) in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = f.type.makeSubtype(name, subName: f.name, level: level + 1)
            fieldDeclaration += ("let \(f.name.pascalCasedString.swiftKeywordEscaped): \(typeName)")
            return (fieldDeclaration, subTypeDeclaration)
        }
        ret += Set(fieldsAndTypes.lazy.flatMap { $0.type.map({"\($0)\n"})}).sort(<).joinWithSeparator("")
        ret += fieldsAndTypes.lazy.map { $0.field.indent(level + 1) }.sort { $0.0.localizedStandardCompare($0.1) == .OrderedAscending }.joinWithSeparator("\n") + "\n"
        return ret + "}".indent(level)
    }
    
    private func createEnumDeclaration(name: String, cases: [ModelParser.FieldType], level: Int = 0) -> String {
        var ret = "enum \(name) {\n".indent(level)
        ret += cases.map { c -> String in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = c.makeSubtype(name, subName: "\(name)\(c.enumCaseName)", level: level + 1)
            if let subTypeDeclaration = subTypeDeclaration {
                fieldDeclaration += "\n" + subTypeDeclaration + "\n"
            }
            fieldDeclaration += "case \(c.enumCaseName)(\(typeName))".indent(level + 1)
            return fieldDeclaration
            }.joinWithSeparator("\n")
        return ret + "\n" + "}".indent(level)
    }
    
    
}
