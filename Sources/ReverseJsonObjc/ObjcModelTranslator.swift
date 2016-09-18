import Foundation
import ReverseJsonCore

public struct ObjcModelCreator: ModelTranslator {
    
    public init(args: [String] = []) {
        self.atomic = args.contains("-a") || args.contains("--atomic")
        self.readonly = !(args.contains("-m") || args.contains("--mutable"))
        if let index = args.index(where: { $0 == "-p" || $0 == "--prefix" }) , args.count > index + 1 {
            self.typePrefix = args[index + 1]
        }
    }
    
    private var atomic = false
    private var readonly = true
    private var typePrefix = ""
    private var atomicyModifier: String {
        return (atomic ? "atomic" : "nonatomic")
    }
    
    public func translate(_ type: FieldType, name: String) -> String {
        let a = declarationsFor(type, name: name, valueToParse: "jsonValue")
        return String(joined:
                ["#import <Foundation/Foundation.h>"]
                + a.interfaces.sorted()
                + a.implementations.sorted(), separator: "\n\n")
    }
    
    public func isNullable(_ type: FieldType) -> Bool {
        switch type {
        case .optional:
            return true
        default:
            return false
        }
    }
    
    func memoryManagementModifier(_ type: FieldType) -> String {
        switch type {
        case .optional(.number), .text:
            return "copy"
        case .number:
            return "assign"
        default:
            return "strong"
        }
    }
    
    private func declarationsFor(_ type: FieldType, name: String, valueToParse: String) -> (interfaces: Set<String>, implementations: Set<String>, parseExpression: String, fieldRequiredTypeNames: Set<String>, fullTypeName: String) {
        switch type {
        case let .enum(enumTypes):
            let className = "\(typePrefix)\(name.camelCasedString)"
            let fieldValues = enumTypes.sorted{$0.0.enumCaseName < $0.1.enumCaseName}.map { type -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<String>, implementations: Set<String>) in
                let nullable = isNullable(type)
                
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName) = declarationsFor(type, name: "\(name.camelCasedString)\(type.enumCaseName.camelCasedString)", valueToParse: "jsonValue")
                
                var modifiers = [atomicyModifier, memoryManagementModifier(type)]
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
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let properties = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.property}
            let initializations = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.initialization.indent(2)}
            
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
            
        case let .object(fields):
            let className = "\(typePrefix)\(name.camelCasedString)"
            let fieldValues = fields.sorted{$0.0.name < $0.1.name}.map { field -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<String>, implementations: Set<String>) in
                let nullable = isNullable(field.type)
                
                let valueToParse = "dict[@\"\(field.name)\"]"
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName) = declarationsFor(field.type, name: "\(name.camelCasedString)\(field.name.camelCasedString)", valueToParse: valueToParse)

                var modifiers = [atomicyModifier, memoryManagementModifier(field.type)]
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
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let properties = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.property}
            let initializations = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}.map {$0.initialization.indent(2)}
            
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
        case .text:
            return ([], [], "[\(valueToParse) isKindOfClass:[NSString class]] ? \(valueToParse) : nil", [], "NSString *")
        case let .number(numberType):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? [\(valueToParse) \(numberType.objcNSNumberMethod)] : 0", [], numberType.objcNumberType)
        case let .list(origListType):
            var listType = origListType
            if case let .number(numberType) = listType {
                listType = .optional(.number(numberType))
            }
            let subName: String
            if case .list = listType {
                subName = name
            } else {
                subName = "\(name)Item"
            }
            let listTypeValues = declarationsFor(listType, name: subName, valueToParse: "item")
            let subParseExpression: String
            if let lineBreakRange = listTypeValues.parseExpression.range(of: "\n") {
                let firstLine = listTypeValues.parseExpression.substring(to: lineBreakRange.lowerBound)
                let remainingLines = listTypeValues.parseExpression.substring(from: lineBreakRange.lowerBound).indent(3)
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
        case let .optional(.number(numberType)):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? \(valueToParse) : nil", [], "NSNumber/*\(numberType.objcNumberType)*/ *")
        case .optional(let optionalType):
            return declarationsFor(optionalType, name: name, valueToParse: valueToParse)
        case .unknown:
            return ([], [], valueToParse, [], "id<NSObject>")
        }
    }
    
}

extension NumberType {
    fileprivate var objcNumberType: String {
        switch self {
        case .bool: return "BOOL"
        case .int: return "NSInteger"
        case .float: return "float"
        case .double: return "double"
        }
    }
    fileprivate var objcNSNumberMethod: String {
        switch self {
        case .bool: return "boolValue"
        case .int: return "integerValue"
        case .float: return "floatValue"
        case .double: return "doubleValue"
        }
    }
}
