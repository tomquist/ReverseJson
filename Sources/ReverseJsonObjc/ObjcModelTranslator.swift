import Foundation
import ReverseJsonCore

public struct ObjcModelCreator: ModelTranslator {
    
    public var atomic = false
    public var readonly = true
    public var createToJson = false
    public var typePrefix = ""
    private var atomicyModifier: String {
        return (atomic ? "atomic" : "nonatomic")
    }
    
    public init() {}
    
    public func translate(_ type: FieldType, name: String) -> [TranslatorOutput] {
        let a = declarationsFor(type, name: name, valueToParse: "jsonValue")
        var result: [TranslatorOutput] = Array(a.interfaces).sorted(by: { $0.name < $1.name })
        let implementations: [TranslatorOutput] = a.implementations.sorted(by: { $0.name < $1.name })
        result.append(contentsOf: implementations)
        return result
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
    
    struct ObjectiveCDeclaration {
        let interfaces: Set<TranslatorOutput>
        let implementations: Set<TranslatorOutput>
        let parseExpression: String
        let fieldRequiredTypeNames: Set<String>
        let fullTypeName: String
        let toJson: (String) -> String
    }
    
    struct ObjectFieldDeclaration {
        let property: String
        let initialization: String
        let requiredTypeNames: Set<String>
        let fieldTypeName: String
        let interfaces: Set<TranslatorOutput>
        let implementations: Set<TranslatorOutput>
        let toJson: String
    }
    
    private func fieldDeclarationFor(_ type: FieldType, variableNameBase: String? = nil, parentName: String, forceNullable: Bool, valueToParse: String) -> ObjectFieldDeclaration {
        let typeIsNullable = isNullable(type)
        let nullable = forceNullable || typeIsNullable
        let type = forceNullable && !typeIsNullable ? .optional(type) : type
        
        let nonOptionalVariableNameBase = variableNameBase ?? type.objectTypeName
        let variableName = nonOptionalVariableNameBase.pascalCased().asValidObjcIdentifier
        let subDeclaration = declarationsFor(type, name:  "\(parentName)\(nonOptionalVariableNameBase.camelCasedString)", valueToParse: valueToParse)
        
        var modifiers = [atomicyModifier, memoryManagementModifier(type)]
        if (readonly) {
            modifiers.append("readonly")
        }
        if nullable {
            modifiers.append("nullable")
        }
        let modifierList = String(joined: modifiers, separator: ", ")
        let propertyName: String
        if subDeclaration.fullTypeName.hasSuffix("*") {
            propertyName = variableName
        } else {
            propertyName = " \(variableName)"
        }
        let property = "@property (\(modifierList)) \(subDeclaration.fullTypeName)\(propertyName);"
        let initialization = "_\(variableName) = \(subDeclaration.parseExpression);"
        let jsonReturnValue = subDeclaration.toJson("_\(variableName)")
        let toJson: String
        if let variableNameBase = variableNameBase {
            toJson = "ret[@\"\(variableNameBase)\"] = \(jsonReturnValue);"
        } else {
            toJson = "if (_\(variableName)) {\n    return \(jsonReturnValue);\n}"
        }
        return ObjectFieldDeclaration(property: property,
                                      initialization: initialization,
                                      requiredTypeNames: subDeclaration.fieldRequiredTypeNames,
                                      fieldTypeName: subDeclaration.fullTypeName,
                                      interfaces: subDeclaration.interfaces,
                                      implementations: subDeclaration.implementations,
                                      toJson: toJson)
    }
    
    private func declarationsFor(_ type: FieldType, name: String, valueToParse: String, isOptional: Bool = false) -> ObjectiveCDeclaration {
        switch type {
        case let .enum(enumTypeName, enumTypes):
            let className = "\(typePrefix)\(enumTypeName ?? name.camelCasedString)"
            let fieldValues = enumTypes.sorted{$0.enumCaseName < $1.enumCaseName}.map {
                fieldDeclarationFor($0,
                                    parentName: (enumTypeName ?? name.camelCasedString),
                                    forceNullable: enumTypes.count > 1,
                                    valueToParse: "jsonValue")
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let sortedFieldValues = fieldValues.sorted{$0.fieldTypeName < $1.fieldTypeName}
            let properties = sortedFieldValues.map {$0.property}
            let initializations = sortedFieldValues.map {$0.initialization.indent(2)}
            
            var interface = "#import <Foundation/Foundation.h>\n"
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = String(joined: forwardDeclarations, separator: ", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            interface += String(joined: [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
                ] + (createToJson ? ["- (id<NSObject>)toJson;"] : []) + properties + [
                "@end",
                "NS_ASSUME_NONNULL_END",
            ])
            
            let imports = forwardDeclarations.map {"#import \"\($0).h\""}
            var implementationLines = [
                "#import \"\(className).h\"",
                ] + imports + [
                    "@implementation \(className)",
                    "- (instancetype)initWithJsonValue:(id)jsonValue {",
                    "    self = [super init];",
                    "    if (self) {",
            ]
            implementationLines += initializations
            implementationLines += [
                "    }",
                "    return self;",
                "}",
            ]
            if createToJson {
                let toJsonImplementation = sortedFieldValues.map {$0.toJson}.joined(separator: " else ")
                implementationLines += [
                    "- (id<NSObject>)toJson {",
                    toJsonImplementation.indent(1),
                    "    return nil;",
                    "}"
                ]
            }
            implementationLines += [
                "@end"
            ]
            let implementation = String(joined: implementationLines)
            
            let interfaces = fieldValues.lazy.map {$0.interfaces}.reduce(Set([TranslatorOutput(name: "\(className).h", content: interface)])) { $0.union($1) }
            let implementations = fieldValues.lazy.map{$0.implementations}.reduce(Set([TranslatorOutput(name: "\(className).m", content: implementation)])) { $0.union($1) }
            let parseExpression = "[[\(className) alloc] initWithJsonValue:\(valueToParse)]"
            return ObjectiveCDeclaration(interfaces: interfaces,
                                         implementations: implementations,
                                         parseExpression: parseExpression,
                                         fieldRequiredTypeNames: [className],
                                         fullTypeName: "\(className) *",
                                         toJson: { (name: String) in "[\(name) toJson]"})
        case let .object(objectTypeName, fields):
            let className = "\(typePrefix)\(objectTypeName ?? name.camelCasedString)"
            let fieldValues = fields.sorted{$0.name < $1.name}.map {
                fieldDeclarationFor($0.type,
                                    variableNameBase: $0.name,
                                    parentName: objectTypeName ?? name.camelCasedString,
                                    forceNullable: false,
                                    valueToParse: "dict[@\"\($0.name)\"]") }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let sortedFieldValues = fieldValues.sorted{$0.fieldTypeName < $1.fieldTypeName}
            let properties = sortedFieldValues.map {$0.property}
            let initializations = sortedFieldValues.map {$0.initialization.indent(2)}
            
            var interface = "#import <Foundation/Foundation.h>\n"
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = String(joined: forwardDeclarations, separator: ", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            interface += String(joined: [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id<NSObject>> *)dictionary;",
                "- (nullable instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
            ] + (createToJson ? ["- (NSDictionary<NSString *, id<NSObject>> *)toJson;"] : []) + properties + [
                "@end",
                "NS_ASSUME_NONNULL_END"
            ])
            
            let imports = forwardDeclarations.map {"#import \"\($0).h\""}
            var implementationLines = [
                "#import \"\(className).h\""
            ]
            implementationLines += imports
            implementationLines += [
                "@implementation \(className)",
                "- (instancetype)initWithJsonDictionary:(NSDictionary<NSString *, id> *)dict {",
                "    self = [super init];",
                "    if (self) {",
            ]
            implementationLines += initializations
            implementationLines += [
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
            ]
            if createToJson {
                implementationLines += [
                    "- (NSDictionary<NSString *, id<NSObject>> *)toJson {",
                    "    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:\(sortedFieldValues.count)];",
                ]
                implementationLines += sortedFieldValues.map {$0.toJson.indent(1)}
                implementationLines += [
                    "    return [ret copy];",
                    "}",
                ]
            }
            implementationLines += [
                "@end",
            ]
            let implementation = String(joined: implementationLines)
            
            let interfaces = fieldValues.lazy.map {$0.interfaces}.reduce(Set([TranslatorOutput(name: "\(className).h", content: interface)])) { $0.union($1) }
            let implementations = fieldValues.lazy.map{$0.implementations}.reduce(Set([TranslatorOutput(name: "\(className).m", content: implementation)])) { $0.union($1) }
            var parseExpression = "[[\(className) alloc] initWithJsonValue:\(valueToParse)]"
            if !isOptional {
                parseExpression = "(\(parseExpression) ?: [[\(className) alloc] initWithJsonDictionary:@{}])"
            }
            return ObjectiveCDeclaration(interfaces: interfaces,
                                         implementations: implementations,
                                         parseExpression: parseExpression,
                                         fieldRequiredTypeNames: [className],
                                         fullTypeName: "\(className) *",
                                         toJson: { (name: String) in "[\(name) toJson]"})
        case .text:
            let fallback = isOptional ? "nil" : "@\"\""
            return ObjectiveCDeclaration(interfaces: [],
                                         implementations: [],
                                         parseExpression: "[\(valueToParse) isKindOfClass:[NSString class]] ? \(valueToParse) : \(fallback)",
                                         fieldRequiredTypeNames: [],
                                         fullTypeName: "NSString *",
                                         toJson: { $0 })
        case let .number(numberType):
            return ObjectiveCDeclaration(interfaces: [],
                                         implementations: [],
                                         parseExpression: "[\(valueToParse) isKindOfClass:[NSNumber class]] ? [\(valueToParse) \(numberType.objcNSNumberMethod)] : 0",
                                         fieldRequiredTypeNames: [],
                                         fullTypeName: numberType.objcNumberType,
                                         toJson: { (name: String) in "@(\(name))" })
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
                let firstLine = listTypeValues.parseExpression[..<lineBreakRange.lowerBound]
                let remainingLines = String(listTypeValues.parseExpression[lineBreakRange.lowerBound...]).indent(3)
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
            let fallback = isOptional ? "" : " ?: @[]"
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
                "    [values copy]\(fallback);",
                "})"
            )
            let valueToJson = listTypeValues.toJson("item")
            let subValueToJson: String
            if let lineBreakRange = valueToJson.range(of: "\n") {
                let firstLine = valueToJson[..<lineBreakRange.lowerBound]
                let remainingLines = String(valueToJson[lineBreakRange.lowerBound...]).indent(3)
                subValueToJson = "\(firstLine)\n\(remainingLines)"
            } else {
                subValueToJson = valueToJson;
            }
            
            let toJson = { (variableName: String) -> String in
                return String(lines:
                "({",
                "    NSMutableArray<id<NSObject>> *values = nil;",
                "    NSArray *array = \(variableName);",
                "    if (array) {",
                "        values = [NSMutableArray arrayWithCapacity:array.count];",
                "        for (id item in array) {",
                "            if (item == [NSNull null]) {",
                "                [values addObject:item];",
                "            } else {",
                "                id json = \(subValueToJson);",
                "                [values addObject:json ?: (id)[NSNull null]];",
                "            }",
                "        }",
                "    }",
                "    [values copy]\(fallback);",
                "})")
            }
            return ObjectiveCDeclaration(interfaces: listTypeValues.interfaces,
                                         implementations: listTypeValues.implementations,
                                         parseExpression: parseExpression,
                                         fieldRequiredTypeNames: listTypeValues.fieldRequiredTypeNames,
                                         fullTypeName: "NSArray<\(listTypeValues.fullTypeName)> *",
                                         toJson: toJson)
        case let .optional(.number(numberType)):
            return ObjectiveCDeclaration(interfaces: [],
                                         implementations: [],
                                         parseExpression: "[\(valueToParse) isKindOfClass:[NSNumber class]] ? \(valueToParse) : nil",
                                         fieldRequiredTypeNames: [],
                                         fullTypeName: "NSNumber/*\(numberType.objcNumberType)*/ *",
                                         toJson: {$0})
        case .optional(let optionalType):
            return declarationsFor(optionalType, name: name, valueToParse: valueToParse, isOptional: true)
        case .unknown:
            return ObjectiveCDeclaration(interfaces: [],
                                         implementations: [],
                                         parseExpression: valueToParse,
                                         fieldRequiredTypeNames: [],
                                         fullTypeName: "id<NSObject>",
                                         toJson: {$0})
        }
    }
    
}

extension FieldType {
    
    fileprivate var objectTypeName: String {
        switch self {
        case let .object(name?, _):
            return name
        case let .enum(name?, _):
            return name
        case let .optional(type):
            return type.objectTypeName
        default:
            return enumCaseName
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
