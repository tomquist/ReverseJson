import Foundation

extension NSNumber {
    private struct Constants {
        private static let trueNumber = NSNumber(value: true)
        private static let falseNumber = NSNumber(value: false)
        private static let trueObjCType =  String(validatingUTF8: Constants.trueNumber.objCType)
        private static let falseObjCType = String(validatingUTF8: Constants.falseNumber.objCType)
    }
    var isBool:Bool {
        get {
            let objCType = String(validatingUTF8: self.objCType)
            let orderedSame: NSComparisonResult = .orderedSame
            if (self.compare(Constants.trueNumber) == orderedSame && objCType == Constants.trueObjCType)
                || (self.compare(Constants.falseNumber) == orderedSame && objCType == Constants.falseObjCType) {
                return true
            }
            return false
        }
    }
    
    var numberType: ModelParser.NumberType {
        if self.isBool {
            return .Bool
        }
        let mappings: [String: ModelParser.NumberType] = ["c": .Int, "i": .Int, "l": .Int, "q": .Int, "f": .Float, "d": .Double]
        let objcType = String(validatingUTF8: self.objCType)?.lowercased()
        return objcType.flatMap { mappings[$0] } ?? .Double
    }
}

public class ModelParser {
    
    public struct ObjectField {
        public let name: String
        public let type: FieldType
        
        init(name: String, type: FieldType) {
            self.name = name
            self.type = type
        }
    }
    public enum NumberType: String {
        case Bool
        case Int
        case Float
        case Double
    }
    
    public indirect enum FieldType {
        case Object(Set<ObjectField>)
        case List(FieldType)
        case Text
        case Number(NumberType)
        case Enum(Set<FieldType>)
        case Unknown
        case Optional(FieldType)
    }
    
    public enum Error: ErrorProtocol {
        case UnsupportedValueType(Any, Any.Type)
    }
    
    public init() {
        
    }
    
    public func decode(_ value: Any) throws -> FieldType {
        switch value {
        case is String:
            return .Text
        case let number as NSNumber where value is Double: // Only on ios/osx we can bridge numbers to double and NSNumber
            return .Number(number.numberType)
        case is Double:
            return .Number(.Double)
        case is Float:
            return .Number(.Float)
        case is Int:
            return .Number(.Int)
        case is Bool:
            return .Number(.Bool)
        case let subObj as [String: AnyObject]:
            return try decode(dict: subObj)
        case let subObj as [String: Any]:
            return try decode(dict: subObj)
        case let subObj as [AnyObject]:
            if let subType = try decode(list: subObj) {
                return .List(subType)
            } else {
                return .List(.Unknown)
            }
        case let subObj as [Any]:
            if let subType = try decode(list: subObj) {
                return .List(subType)
            } else {
                return .List(.Unknown)
            }
        case is NSNull:
            return .Optional(.Unknown)
        default:
            throw Error.UnsupportedValueType(value, value.dynamicType)
        }
    }
    
    private func decode(dict: [String: AnyObject]) throws -> FieldType {
        let fields = try dict.map { (name: String, value: AnyObject) in
            return ObjectField(name: name, type: try decode(value))
        }
        return .Object(Set(fields))
    }
    
    private func decode(dict: [String: Any]) throws -> FieldType {
        let fields = try dict.map { (name: String, value: Any) in
            return ObjectField(name: name, type: try decode(value))
        }
        return .Object(Set(fields))
    }
    
    private func decode(list: [Any]) throws -> FieldType? {
        let types = try list.flatMap { try decode($0)}
        return types.reduce(nil) { (type1, type2) -> FieldType? in
            if let type1 = type1 {
                return type1.mergeWith(type: type2)
            }
            return type2
        }
    }
    
    private func decode(list: [AnyObject]) throws -> FieldType? {
        let types = try list.flatMap { try decode($0)}
        return types.reduce(nil) { (type1, type2) -> FieldType? in
            if let type1 = type1 {
                return type1.mergeWith(type: type2)
            }
            return type2
        }
    }
    
    
    private class func transformAllFieldsToOptionalImpl(rootField: ModelParser.FieldType) -> ModelParser.FieldType {
        switch rootField {
        case let .Object(fields):
            let mappedFields = fields.map {
                ModelParser.ObjectField(name: $0.name, type: transformAllFieldsToOptionalImpl(rootField: $0.type))
            }
            return .Optional(.Object(Set(mappedFields)))
        case let .List(fieldType):
            return .Optional(.List(transformAllFieldsToOptional(rootField: fieldType)))
        case .Text:
            return .Optional(.Text)
        case let .Number(numberType):
            return .Optional(.Number(numberType))
        case let .Enum(fields):
            let mappedFields = fields.map {
                transformAllFieldsToOptional(rootField: $0)
            }
            return .Optional(.Enum(Set(mappedFields)))
        case .Unknown:
            return .Optional(.Unknown)
        case let .Optional(fieldType):
            return .Optional(transformAllFieldsToOptional(rootField: fieldType))
        }
    }
    
    public class func transformAllFieldsToOptional(rootField: ModelParser.FieldType) -> ModelParser.FieldType {
        switch rootField {
        case let .Object(fields):
            let mappedFields = fields.map {
                ModelParser.ObjectField(name: $0.name, type: transformAllFieldsToOptionalImpl(rootField: $0.type))
            }
            return .Object(Set(mappedFields))
        case let .List(fieldType):
            return .List(transformAllFieldsToOptional(rootField: fieldType))
        case let .Enum(fields):
            let mappedFields = fields.map { transformAllFieldsToOptional(rootField: $0) }
            return .Enum(Set(mappedFields))
        default:
            return rootField
        }
    }
    
}

extension ModelParser.ObjectField: Hashable {
    public var hashValue: Int {
        return (31 &* name.hashValue) &+ type.hashValue
    }
}
public func ==(lhs: ModelParser.ObjectField, rhs: ModelParser.ObjectField) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}

extension ModelParser.FieldType: Hashable {
    public var hashValue: Int {
        switch self {
        case .Unknown:
            return 0
        case .Text:
            return 31
        case let .Optional(type):
            return 31 &+ type.hashValue
        case let .Object(fields):
            return 31 &* 2 &+ fields.hashValue
        case let .List(type):
            return 31 &* 3 &+ type.hashValue
        case let .Enum(types):
            return 31 &* 4 &+ types.hashValue
        case let .Number(numberType):
            return 31 &* 5 &+ numberType.hashValue
        }
    }
}
public func ==(lhs: ModelParser.FieldType, rhs: ModelParser.FieldType) -> Bool {
    switch (lhs, rhs) {
    case let (.Object(fields1), .Object(fields2)):
        return fields1 == fields2
    case let (.List(type1), .List(type2)):
        return type1 == type2
    case (.Text, .Text):
        return true
    case let (.Number(numberType1), .Number(numberType2)):
        return numberType1 == numberType2
    case (.Unknown, .Unknown):
        return true
    case let (.Optional(type1), .Optional(type2)):
        return type1 == type2
    case let (.Enum(types1), .Enum(types2)):
        return types1 == types2
    default:
        return false
    }
}

extension ModelParser.NumberType {
    private func mergeWith(numberType: ModelParser.NumberType) -> ModelParser.NumberType? {
        switch (self, numberType) {
        case let (numberType1, numberType2) where numberType1 == numberType2: return numberType1
        case (.Bool, _), (_, .Bool): return nil
        case (.Double, _), (_, .Double): return .Double
        case (.Float, _), (_, .Float): return .Float
        default: return self // Can't be reached
        }
    }
}

extension ModelParser.FieldType {
    private func mergeWith(type: ModelParser.FieldType) -> ModelParser.FieldType {
        func mergeEnumTypes(enumTypes: Set<ModelParser.FieldType>, otherType: ModelParser.FieldType) -> Set<ModelParser.FieldType> {
            if enumTypes.contains(otherType) {
                return enumTypes
            }
            var merged = false
            let newEnumTypes: [ModelParser.FieldType] = enumTypes.map { enumType in
                switch (enumType, otherType) {
                case let (.Optional(type1), type2):
                    merged = true
                    if case let .Optional(type2) = type2 {
                        return .Optional(type1.mergeWith(type: type2))
                    } else {
                        return .Optional(type1.mergeWith(type: type2))
                    }
                case let (type1, .Optional(type2)):
                    merged = true
                    if case let .Optional(type1) = type1 {
                        return .Optional(type1.mergeWith(type: type2))
                    } else {
                        return .Optional(type1.mergeWith(type: type2))
                    }
                case let (.Unknown, knownType):
                    merged = true
                    return knownType
                case let (knownType, .Unknown):
                    merged = true
                    return knownType
                case (.Object, .Object):
                    merged = true
                    return enumType.mergeWith(type: otherType)
                case let (.Number(numberType1), .Number(numberType2)) where numberType1.mergeWith(numberType: numberType2) != nil:
                    merged = true
                    let mergedNumberType = numberType1.mergeWith(numberType: numberType2)!
                    return .Number(mergedNumberType)
                case let (.List(listType1), .List(listType2)):
                    merged = true
                    return .List(listType1.mergeWith(type: listType2))
                default:
                    return enumType
                }
            }
            return Set(newEnumTypes + (merged ? [] : [otherType]))
        }
        
        switch (self, type) {
        case let (type1, type2) where type1 == type2:
            return type1
        case let (.Optional(type1), type2):
            if case let .Optional(type2) = type2 {
                return .Optional(type1.mergeWith(type: type2))
            } else {
                return .Optional(type1.mergeWith(type: type2))
            }
        case let (type1, .Optional(type2)):
            if case let .Optional(type1) = type1 {
                return .Optional(type1.mergeWith(type: type2))
            } else {
                return .Optional(type1.mergeWith(type: type2))
            }
        case let (.Unknown, knownType):
            return knownType
        case let (knownType, .Unknown):
            return knownType
        case let (.Number(numberType1), .Number(numberType2)) where numberType1.mergeWith(numberType: numberType2) != nil:
            let mergedNumberType = numberType1.mergeWith(numberType: numberType2)!
            return .Number(mergedNumberType)
        case let (.Object(fields1), .Object(fields2)):
            var resultFields: Set<ModelParser.ObjectField> = []
            var remainingFields = fields2
            for f1 in fields1 {
                let foundItemIndex = remainingFields.index { f -> Bool in
                    return f1.name == f.name
                }
                let field: ModelParser.ObjectField
                if let foundItemIndex = foundItemIndex {
                    let foundItem = remainingFields.remove(at: foundItemIndex)
                    let mergedType = f1.type.mergeWith(type: foundItem.type)
                    field = ModelParser.ObjectField(name: f1.name, type: mergedType)
                } else if case .Optional = f1.type {
                    field = f1
                } else {
                    field = ModelParser.ObjectField(name: f1.name, type: .Optional(f1.type))
                }
                resultFields.insert(field)
            }
            for field in remainingFields {
                if case .Optional = field.type {
                    resultFields.insert(field)
                } else {
                    resultFields.insert(ModelParser.ObjectField(name: field.name, type: .Optional(field.type)))
                }
            }
            return .Object(resultFields)
        case let (.List(listType1), .List(listType2)):
            return .List(listType1.mergeWith(type: listType2))
        case let (.Enum(enumTypes), type):
            return .Enum(mergeEnumTypes(enumTypes: enumTypes, otherType: type))
        case let (type, .Enum(enumTypes)):
            return .Enum(mergeEnumTypes(enumTypes: enumTypes, otherType: type))
        default:
            return .Enum([self, type])
        }
    }
}


