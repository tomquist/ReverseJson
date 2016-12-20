import CoreJSON

public struct ObjectField {
    public let name: String
    public let type: FieldType
    
    public init(name: String, type: FieldType) {
        self.name = name
        self.type = type
    }
}
public enum NumberType: String {
    case bool = "Bool"
    case int = "Int"
    case float = "Float"
    case double = "Double"
}

public indirect enum FieldType {
    case object(name: String?, Set<ObjectField>)
    case list(FieldType)
    case text
    case number(NumberType)
    case `enum`(name: String?, Set<FieldType>)
    case unknown(name: String?)
    case optional(FieldType)
}

extension FieldType {
    public static func unnamedObject(_ fields: Set<ObjectField>) -> FieldType {
        return .object(name: nil, fields)
    }
    public static func unnamedEnum(_ subTypes: Set<FieldType>) -> FieldType {
        return .enum(name: nil, subTypes)
    }
    public static var unnamedUnknown: FieldType {
        return .unknown(name: nil)
    }
}

extension FieldType {
    public var isOptional: Bool {
        switch self {
        case .optional: return true
        default: return false
        }
    }
    
    public var unwrapOptional: FieldType {
        switch self {
        case let .optional(type):
            return type.unwrapOptional
        default:
            return self
        }
    }
}

public struct ModelGenerator {
    
    public var allFieldsOptional = false
    
    public init() {}
    
    public func decode(_ value: JSON) -> FieldType {
        let fieldType = internalDecode(value)
        if allFieldsOptional {
            return ModelGenerator.transformAllFieldsToOptional(fieldType)
        }
        return fieldType
    }
    
    public func internalDecode(_ value: JSON) -> FieldType {
        switch value {
        case .string: return .text
        case let .number(number):
            switch number {
            case .int: return .number(.int)
            case .int64: return .number(.int)
            case .float: return .number(.float)
            case .uint: return .number(.int)
            case .uint64: return .number(.int)
            case .double: return .number(.double)
            }
        case .bool: return .number(.bool)
        case .null: return .optional(.unnamedUnknown)
        case let .object(object):
            return decode(object)
        case let .array(array):
            if let subType = decode(array) {
                return .list(subType)
            } else {
                return .list(.unnamedUnknown)
            }
        }
    }
    
    private func decode(_ dict: [String: JSON]) -> FieldType {
        let fields = dict.map { (name: String, value: JSON) in
            return ObjectField(name: name, type: internalDecode(value))
        }
        return .object(name: nil, Set(fields))
    }
    
    private func decode(_ list: [JSON]) -> FieldType? {
        let types = list.flatMap(internalDecode)
        return types.reduce(nil) { (type1, type2) -> FieldType? in
            if let type1 = type1 {
                return type1.mergeWith(type2)
            }
            return type2
        }
    }
    
    private static func transformAllFieldsToOptionalImpl(_ rootField: FieldType) -> FieldType {
        switch rootField {
        case let .object(name, fields):
            let mappedFields = fields.map {
                ObjectField(name: $0.name, type: transformAllFieldsToOptionalImpl($0.type))
            }
            return .optional(.object(name: name, Set(mappedFields)))
        case let .list(fieldType):
            return .optional(.list(transformAllFieldsToOptional(fieldType)))
        case .text:
            return .optional(.text)
        case let .number(numberType):
            return .optional(.number(numberType))
        case let .enum(name, fields):
            let mappedFields = fields.map {
                transformAllFieldsToOptional($0)
            }
            return .optional(.enum(name: name, Set(mappedFields)))
        case .unknown:
            return .optional(.unnamedUnknown)
        case let .optional(fieldType):
            return .optional(transformAllFieldsToOptional(fieldType))
        }
    }
    
    static func transformAllFieldsToOptional(_ rootField: FieldType) -> FieldType {
        switch rootField {
        case let .object(name, fields):
            let mappedFields = fields.map {
                ObjectField(name: $0.name, type: transformAllFieldsToOptionalImpl($0.type))
            }
            return .object(name: name, Set(mappedFields))
        case let .list(fieldType):
            return .list(transformAllFieldsToOptional(fieldType))
        case let .enum(name, fields):
            let mappedFields = fields.map { transformAllFieldsToOptional($0) }
            return .enum(name: name, Set(mappedFields))
        default:
            return rootField
        }
    }
    
}

extension ObjectField: Hashable {
    public var hashValue: Int {
        return (31 &* name.hashValue) &+ type.hashValue
    }
    
    public static func ==(lhs: ObjectField, rhs: ObjectField) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}

extension FieldType: Hashable {
    public var hashValue: Int {
        switch self {
        case .unknown:
            return 0
        case .text:
            return 31
        case let .optional(type):
            return 31 &+ type.hashValue
        case let .object(name, fields):
            return 31 &* 2 &+ (name?.hashValue ?? 0) &+ fields.hashValue
        case let .list(type):
            return 31 &* 3 &+ type.hashValue
        case let .enum(name, types):
            return 31 &* 4 &+ (name?.hashValue ?? 0) &+ types.hashValue
        case let .number(numberType):
            return 31 &* 5 &+ numberType.hashValue
        }
    }
    
    public static func ==(lhs: FieldType, rhs: FieldType) -> Bool {
        switch (lhs, rhs) {
        case let (.object(name1, fields1), .object(name2, fields2)):
            return fields1 == fields2 && name1 == name2
        case let (.list(type1), .list(type2)):
            return type1 == type2
        case (.text, .text):
            return true
        case let (.number(numberType1), .number(numberType2)):
            return numberType1 == numberType2
        case let (.unknown(name1), .unknown(name2)):
            return name1 == name2
        case let (.optional(type1), .optional(type2)):
            return type1 == type2
        case let (.enum(name1, types1), .enum(name2, types2)):
            return types1 == types2 && name1 == name2
        default:
            return false
        }
    }
}

extension NumberType {
    fileprivate func mergeWith(_ numberType: NumberType) -> NumberType? {
        switch (self, numberType) {
        case let (numberType1, numberType2) where numberType1 == numberType2: return numberType1
        case (.bool, _), (_, .bool): return nil
        case (.double, _), (_, .double): return .double
        case (.float, _), (_, .float): return .float
        default: return self // Can't be reached
        }
    }
}

extension FieldType {
    fileprivate func mergeWith(_ type: FieldType) -> FieldType {
        func mergeEnumTypes(_ enumTypes: Set<FieldType>, otherType: FieldType) -> Set<FieldType> {
            if enumTypes.contains(otherType) {
                return enumTypes
            }
            var merged = false
            let newEnumTypes: [FieldType] = enumTypes.map { enumType in
                switch (enumType, otherType) {
                case let (.optional(type1), type2), let (type2, .optional(type1)):
                    merged = true
                    if case let .optional(type2) = type2 {
                        return .optional(type1.mergeWith(type2))
                    } else {
                        return .optional(type1.mergeWith(type2))
                    }
                case let (.unknown, knownType), let (knownType, .unknown):
                    merged = true
                    return knownType
                case (.object, .object):
                    merged = true
                    return enumType.mergeWith(otherType)
                case let (.number(numberType1), .number(numberType2)) where numberType1.mergeWith(numberType2) != nil:
                    merged = true
                    let mergedNumberType = numberType1.mergeWith(numberType2)!
                    return .number(mergedNumberType)
                case let (.list(listType1), .list(listType2)):
                    merged = true
                    return .list(listType1.mergeWith(listType2))
                default:
                    return enumType
                }
            }
            return Set(newEnumTypes + (merged ? [] : [otherType]))
        }
        
        switch (self, type) {
        case let (type1, type2) where type1 == type2:
            return type1
        case let (.optional(type1), type2), let (type2, .optional(type1)):
            return .optional(type1.mergeWith(type2))
        case let (.unknown, knownType), let (knownType, .unknown):
            return knownType
        case let (.number(numberType1), .number(numberType2)) where numberType1.mergeWith(numberType2) != nil:
            let mergedNumberType = numberType1.mergeWith(numberType2)!
            return .number(mergedNumberType)
        case let (.object(name1, fields1), .object(name2, fields2)) where name1 == name2:
            var resultFields: Set<ObjectField> = []
            var remainingFields = fields2
            for f1 in fields1 {
                let foundItemIndex = remainingFields.index { f -> Bool in
                    return f1.name == f.name
                }
                let field: ObjectField
                if let foundItemIndex = foundItemIndex {
                    let foundItem = remainingFields.remove(at: foundItemIndex)
                    let mergedType = f1.type.mergeWith(foundItem.type)
                    field = ObjectField(name: f1.name, type: mergedType)
                } else if case .optional = f1.type {
                    field = f1
                } else {
                    field = ObjectField(name: f1.name, type: .optional(f1.type))
                }
                resultFields.insert(field)
            }
            for field in remainingFields {
                if case .optional = field.type {
                    resultFields.insert(field)
                } else {
                    resultFields.insert(ObjectField(name: field.name, type: .optional(field.type)))
                }
            }
            return .object(name: name1, resultFields)
        case let (.list(listType1), .list(listType2)):
            return .list(listType1.mergeWith(listType2))
        case let (.enum(name, enumTypes), type), let (type, .enum(name, enumTypes)):
            return .enum(name: name, mergeEnumTypes(enumTypes, otherType: type))
        default:
            return .enum(name: nil, [self, type])
        }
    }
}


