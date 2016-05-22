
public struct ObjcModelCreator: ModelTranslator {
    
    public init(args: [String] = []) {
        self.atomic = args.contains("-a") || args.contains("--atomic")
        self.readonly = !(args.contains("-m") || args.contains("--mutable"))
        if let index = args.index (where: { $0 == "-p" || $0 == "--prefix" }) where args.count > index + 1 {
            self.typePrefix = args[index + 1]
        }
    }
    
    private var atomic = false
    private var readonly = true
    private var typePrefix = ""
    private var atomicyModifier: String {
        return (atomic ? "atomic" : "nonatomic")
    }
    
    public func translate(_ type: ModelParser.FieldType, name: String) -> String {
        let a = declarationsFor(type: type, name: name, valueToParse: "jsonValue")
        let sortedInterfaces = a.interfaces.sorted()
        let sortedImplementations = a.implementations.sorted()
        return String(joined:
                ["#import <Foundation/Foundation.h>"]
                + sortedInterfaces
                + sortedImplementations, separator: "\n\n")
    }
    
    public func isNullable(type: ModelParser.FieldType) -> Bool {
        switch type {
        case .Optional:
            return true
        default:
            return false
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
            let className = "\(typePrefix)\(name.camelCased())"
            let sortedEnumTypes = enumTypes.sorted {$0.0.enumCaseName < $0.1.enumCaseName}
            let fieldValues = sortedEnumTypes.map { type -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<String>, implementations: Set<String>) in
                let nullable = isNullable(type: type)
                
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName) = declarationsFor(type: type, name: "\(name.camelCased())\(type.enumCaseName.camelCased())", valueToParse: "jsonValue")
                
                var modifiers = [atomicyModifier, memoryManagementModifier(type: type)]
                if (readonly) {
                    modifiers.append("readonly")
                }
                if nullable {
                    modifiers.append("nullable")
                }
                let modifierList = String(joined: modifiers, separator: ", ")
                let variableName = type.enumCaseName.pascalCased()
                let propertyName: String
                if fieldFullTypeName.hasSuffix("*") {
                    propertyName = variableName
                } else {
                    propertyName = " \(variableName)"
                }
                let property = "@property (\(modifierList)) \(fieldFullTypeName)\(propertyName);"
                let initialization = "_\(variableName) = \(parseExpression);"
                return (property, initialization, fieldRequiredTypeNames, fieldFullTypeName, subInterfaces, subImplementations)
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(isOrderedBefore: <)
            let sortedFieldValues = fieldValues.sorted {$0.0.fieldTypeName < $0.1.fieldTypeName}
            let properties = sortedFieldValues.map {$0.property}
            let initializations = sortedFieldValues.map {$0.initialization.indent(level: 2)}
            
            var interface = ""
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = String(joined: forwardDeclarations, separator: ", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            interface += String(joined: [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            ] + properties + [
                "@end",
                "NS_ASSUME_NONNULL_END",
            ])
            
            let implementation = String(joined: [
                "@implementation \(className)",
                "- (instancetype)initWithJsonValue:(id)jsonValue {",
                "    self = [super init];",
                "    if (self) {",
            ] + initializations + [
                "    }",
                "    return self;",
                "}",
                "@end",
            ])
            
            let interfaces = fieldValues.lazy.map {$0.interfaces}.reduce(Set([interface])) { $0.union($1) }
            let implementations = fieldValues.lazy.map{$0.implementations}.reduce(Set([implementation])) { $0.union($1) }
            let parseExpression = "[[\(className) alloc] initWithJsonValue:\(valueToParse)]"
            return (interfaces, implementations, parseExpression, [className], "\(className) *")
            
        case let .Object(fields):
            let className = "\(typePrefix)\(name.camelCased())"
            let sortedFields = fields.sorted {$0.0.name < $0.1.name}
            let fieldValues = sortedFields.map { field -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<String>, implementations: Set<String>) in
                let nullable = isNullable(type: field.type)
                
                let valueToParse = "dict[@\"\(field.name)\"]"
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName) = declarationsFor(type: field.type, name: "\(name.camelCased())\(field.name.camelCased())", valueToParse: valueToParse)

                var modifiers = [atomicyModifier, memoryManagementModifier(type: field.type)]
                if (readonly) {
                    modifiers.append("readonly")
                }
                if nullable {
                    modifiers.append("nullable")
                }
                let modifierList = String(joined: modifiers, separator: ", ")
                let variableName = field.name.pascalCased()
                let propertyName: String
                if fieldFullTypeName.hasSuffix("*") {
                    propertyName = variableName
                } else {
                    propertyName = " \(variableName)"
                }
                let property = "@property (\(modifierList)) \(fieldFullTypeName)\(propertyName);"
                let initialization = "_\(variableName) = \(parseExpression);"
                return (property, initialization, fieldRequiredTypeNames, fieldFullTypeName, subInterfaces, subImplementations)
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(isOrderedBefore: <)
            let sortedFieldValues = fieldValues.sorted {$0.0.fieldTypeName < $0.1.fieldTypeName}
            let properties = sortedFieldValues.map {$0.property}
            let initializations = sortedFieldValues.map {$0.initialization.indent(level: 2)}
            
            var interface = ""
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = String(joined: forwardDeclarations, separator: ", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            interface += String(joined: [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
                "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            ] + properties + [
                "@end",
                "NS_ASSUME_NONNULL_END"
            ])
            
            let implementation = String(joined: [
                "@implementation \(className)",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
                "    self = [super init];",
                "    if (self) {",
            ] + initializations + [
                "    }",
                "    return self;",
                "}",
                "- (instancetype)initWithJsonValue:(id)jsonValue {",
                "    if ([jsonValue isKindOfClass:[NSDictionary class]]) {",
                "        self = [self initWithJsonDictionary:jsonValue];",
                "    } else {",
                "        self = nil;",
                "    }",
                "    return self;",
                "}",
                "@end",
            ])
            
            let interfaces = fieldValues.lazy.map {$0.interfaces}.reduce(Set([interface])) { $0.union($1) }
            let implementations = fieldValues.lazy.map{$0.implementations}.reduce(Set([implementation])) { $0.union($1) }
            let parseExpression = "[[\(className) alloc] initWithJsonValue:\(valueToParse)]"
            return (interfaces, implementations, parseExpression, [className], "\(className) *")
        case .Text:
            return ([], [], "[\(valueToParse) isKindOfClass:[NSString class]] ? \(valueToParse) : nil", [], "NSString *")
        case let .Number(numberType):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? [\(valueToParse) \(numberType.objcNSNumberMethod)] : 0", [], numberType.objcNumberType)
        case let .List(origListType):
            var listType = origListType
            if case let .Number(numberType) = listType {
                listType = .Optional(.Number(numberType))
            }
            let subName: String
            if case .List = listType {
                subName = name
            } else {
                subName = "\(name)Item"
            }
            let listTypeValues = declarationsFor(type: listType, name: subName, valueToParse: "item")
            let subParseExpression: String
            if let lineBreakRange = listTypeValues.parseExpression.range(of: "\n") {
                let firstLine = listTypeValues.parseExpression.substring(to: lineBreakRange.startIndex)
                let remainingLines = listTypeValues.parseExpression.substring(from: lineBreakRange.startIndex).indent(level: 3)
                subParseExpression = "\(firstLine)\n\(remainingLines)"
            } else {
                subParseExpression = listTypeValues.parseExpression;
            }
            let listTypeName: String
            if listTypeValues.fullTypeName.hasSuffix("*") {
                listTypeName = listTypeValues.fullTypeName
            } else {
                listTypeName = "\(listTypeValues.fullTypeName) "
            }
            let parseExpression = String(lines:
                "({",
                "    id value = \(valueToParse);",
                "    NSMutableArray<\(listTypeValues.fullTypeName)> *values = nil;",
                "    if ([value isKindOfClass:[NSArray class]]) {",
                "        NSArray *array = value;",
                "        values = [NSMutableArray arrayWithCapacity:array.count];",
                "        for (id item in array) {",
                "            \(listTypeName)parsedItem = \(subParseExpression);",
                "            [values addObject:parsedItem ?: (id)[NSNull null]];",
                "        }",
                "    }",
                "    [values copy];",
                "})"
            )
            return (listTypeValues.interfaces, listTypeValues.implementations, parseExpression, listTypeValues.fieldRequiredTypeNames, "NSArray<\(listTypeValues.fullTypeName)> *")
        case let .Optional(.Number(numberType)):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? \(valueToParse) : nil", [], "NSNumber/*\(numberType.objcNumberType)*/ *")
        case .Optional(let optionalType):
            return declarationsFor(type: optionalType, name: name, valueToParse: valueToParse)
        case .Unknown:
            return ([], [], valueToParse, [], "id<NSObject>")
        }
    }
    
}

extension ModelParser.NumberType {
    private var objcNumberType: String {
        switch self {
        case .Bool: return "BOOL"
        case .Int: return "NSInteger"
        case .Float: return "float"
        case .Double: return "double"
        }
    }
    private var objcNSNumberMethod: String {
        switch self {
        case .Bool: return "boolValue"
        case .Int: return "integerValue"
        case .Float: return "floatValue"
        case .Double: return "doubleValue"
        }
    }
}
