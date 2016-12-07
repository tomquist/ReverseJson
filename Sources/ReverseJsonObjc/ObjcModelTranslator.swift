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
    
    private func declarationsFor(_ type: FieldType, name: String, valueToParse: String, isOptional: Bool = false) -> (interfaces: Set<TranslatorOutput>, implementations: Set<TranslatorOutput>, parseExpression: String, fieldRequiredTypeNames: Set<String>, fullTypeName: String, toJson: (String) -> String) {
        switch type {
        case let .enum(enumTypes):
            let className = "\(typePrefix)\(name.camelCasedString)"
            let fieldValues = enumTypes.sorted{$0.0.enumCaseName < $0.1.enumCaseName}.map { type -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<TranslatorOutput>, implementations: Set<TranslatorOutput>, toJson: String) in
                let nullable = isNullable(type) || enumTypes.count > 1
                let enumCaseType = nullable && !isNullable(type) ? .optional(type) : type
                
                let variableName = type.enumCaseName.pascalCased().asValidObjcIdentifier
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName, toJsonValue) = declarationsFor(enumCaseType, name: "\(name.camelCasedString)\(type.enumCaseName.camelCasedString)", valueToParse: "jsonValue")
                
                var modifiers = [atomicyModifier, memoryManagementModifier(enumCaseType)]
                if (readonly) {
                    modifiers.append("readonly")
                }
                if nullable {
                    modifiers.append("nullable")
                }
                let modifierList = String(joined: modifiers, separator: ", ")
                let propertyName: String
                if fieldFullTypeName.hasSuffix("*") {
                    propertyName = variableName
                } else {
                    propertyName = " \(variableName)"
                }
                let property = "@property (\(modifierList)) \(fieldFullTypeName)\(propertyName);"
                let initialization = "_\(variableName) = \(parseExpression);"
                let jsonReturnValue = toJsonValue("_\(variableName)")
                let toJson = "if (_\(variableName)) {\n    return \(jsonReturnValue);\n}"
                return (property, initialization, fieldRequiredTypeNames, fieldFullTypeName, subInterfaces, subImplementations, toJson)
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let sortedFieldValues = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}
            let properties = sortedFieldValues.map {$0.property}
            let initializations = sortedFieldValues.map {$0.initialization.indent(2)}
            
            var interface = "#import <Foundation/Foundation.h>\n"
            if !forwardDeclarations.isEmpty {
                let forwardDeclarationList = String(joined: forwardDeclarations, separator: ", ")
                interface += "@class \(forwardDeclarationList);\n"
            }
            let toJsonNullability = isOptional ? "nullable " : ""
            interface += String(joined: [
                "NS_ASSUME_NONNULL_BEGIN",
                "@interface \(className) : NSObject",
                "- (instancetype)initWithJsonValue:(nullable id<NSObject>)jsonValue;",
                ] + (createToJson ? ["- (\(toJsonNullability)id<NSObject>)toJson;"] : []) + properties + [
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
            return (interfaces, implementations, parseExpression, [className], "\(className) *", { (name: String) in "[\(name) toJson]"})
            
        case let .object(fields):
            let className = "\(typePrefix)\(name.camelCasedString)"
            let fieldValues = fields.sorted{$0.0.name < $0.1.name}.map { field -> (property: String, initialization: String, requiredTypeNames: Set<String>, fieldTypeName: String, interfaces: Set<TranslatorOutput>, implementations: Set<TranslatorOutput>, toJson: String) in
                let nullable = isNullable(field.type)
                
                let valueToParse = "dict[@\"\(field.name)\"]"
                let variableName = field.name.pascalCased().asValidObjcIdentifier
                let (subInterfaces, subImplementations, parseExpression, fieldRequiredTypeNames, fieldFullTypeName, toJsonValue) = declarationsFor(field.type, name: "\(name.camelCasedString)\(field.name.camelCasedString)", valueToParse: valueToParse)

                var modifiers = [atomicyModifier, memoryManagementModifier(field.type)]
                if (readonly) {
                    modifiers.append("readonly")
                }
                if nullable {
                    modifiers.append("nullable")
                }
                let modifierList = String(joined: modifiers, separator: ", ")
                let propertyName: String
                if fieldFullTypeName.hasSuffix("*") {
                    propertyName = variableName
                } else {
                    propertyName = " \(variableName)"
                }
                let property = "@property (\(modifierList)) \(fieldFullTypeName)\(propertyName);"
                let initialization = "_\(variableName) = \(parseExpression);"
                let jsonValue = toJsonValue("_\(variableName)")
                let toJson = "ret[@\"\(field.name)\"] = \(jsonValue);"
                return (property, initialization, fieldRequiredTypeNames, fieldFullTypeName, subInterfaces, subImplementations, toJson)
            }
            let requiredTypeNames = Set(fieldValues.flatMap{$0.requiredTypeNames})
            let forwardDeclarations = requiredTypeNames.sorted(by: <)
            let sortedFieldValues = fieldValues.sorted{$0.0.fieldTypeName < $0.1.fieldTypeName}
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
            return (interfaces, implementations, parseExpression, [className], "\(className) *", { (name: String) in "[\(name) toJson]"})
        case .text:
            let fallback = isOptional ? "nil" : "@\"\""
            return ([], [], "[\(valueToParse) isKindOfClass:[NSString class]] ? \(valueToParse) : \(fallback)", [], "NSString *", { $0 })
        case let .number(numberType):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? [\(valueToParse) \(numberType.objcNSNumberMethod)] : 0", [], numberType.objcNumberType, { (name: String) in "@(\(name))" })
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
                let firstLine = valueToJson.substring(to: lineBreakRange.lowerBound)
                let remainingLines = valueToJson.substring(from: lineBreakRange.lowerBound).indent(3)
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
            return (listTypeValues.interfaces, listTypeValues.implementations, parseExpression, listTypeValues.fieldRequiredTypeNames, "NSArray<\(listTypeValues.fullTypeName)> *", toJson)
        case let .optional(.number(numberType)):
            return ([], [], "[\(valueToParse) isKindOfClass:[NSNumber class]] ? \(valueToParse) : nil", [], "NSNumber/*\(numberType.objcNumberType)*/ *", {$0})
        case .optional(let optionalType):
            return declarationsFor(optionalType, name: name, valueToParse: valueToParse, isOptional: true)
        case .unknown:
            return ([], [], valueToParse, [], "id<NSObject>", {$0})
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
