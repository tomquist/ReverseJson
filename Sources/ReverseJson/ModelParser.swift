import Foundation


extension NSNumber {
    private struct Constants {
        private static let trueNumber = NSNumber(bool: true)
        private static let falseNumber = NSNumber(bool: false)
        private static let trueObjCType = String.fromCString(Constants.trueNumber.objCType)
        private static let falseObjCType = String.fromCString(Constants.falseNumber.objCType)
    }
    var isBool:Bool {
        get {
            let objCType = String.fromCString(self.objCType)
            if (self.compare(Constants.trueNumber) == NSComparisonResult.OrderedSame && objCType == Constants.trueObjCType)
                || (self.compare(Constants.falseNumber) == NSComparisonResult.OrderedSame && objCType == Constants.falseObjCType){
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
        let objcType = String.fromCString(self.objCType)?.lowercaseString
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
    
    public enum Error: ErrorType {
        case UnsupportedValueType(Any)
    }
    
    public init() {
        
    }
    
    public func decode(value: Any) throws -> FieldType {
        switch value {
        case is String:
            return .Text
        case let number as NSNumber:
            return .Number(number.numberType)
        case let subObj as NSDictionary:
            return try decode(subObj)
        case let subObj as NSArray:
            if let subType = try decode(subObj) {
                return .List(subType)
            } else {
                return .List(.Unknown)
            }
        case is NSNull:
            return .Optional(.Unknown)
        default:
            throw Error.UnsupportedValueType(value)
        }
    }
    
    private func decode(dict: NSDictionary) throws -> FieldType {
        let fields = try dict.flatMap{ (name: AnyObject, value: AnyObject) throws -> ObjectField? in
            return try (name as? String).map { ObjectField(name: $0, type: try decode(value)) }
        }
        return .Object(Set(fields))
    }
    
    private func decode(list: NSArray) throws -> FieldType? {
        let types = try list.flatMap { try decode($0)}
        return types.reduce(nil) { (type1, type2) -> FieldType? in
            if let type1 = type1 {
                return type1.mergeWith(type2)
            }
            return type2
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
                        return .Optional(type1.mergeWith(type2))
                    } else {
                        return .Optional(type1.mergeWith(type2))
                    }
                case let (type1, .Optional(type2)):
                    merged = true
                    if case let .Optional(type1) = type1 {
                        return .Optional(type1.mergeWith(type2))
                    } else {
                        return .Optional(type1.mergeWith(type2))
                    }
                case let (.Unknown, knownType):
                    merged = true
                    return knownType
                case let (knownType, .Unknown):
                    merged = true
                    return knownType
                case (.Object, .Object):
                    merged = true
                    return enumType.mergeWith(otherType)
                case let (.Number(numberType1), .Number(numberType2)) where numberType1.mergeWith(numberType2) != nil:
                    merged = true
                    let mergedNumberType = numberType1.mergeWith(numberType2)!
                    return .Number(mergedNumberType)
                case let (.List(listType1), .List(listType2)):
                    merged = true
                    return .List(listType1.mergeWith(listType2))
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
                return .Optional(type1.mergeWith(type2))
            } else {
                return .Optional(type1.mergeWith(type2))
            }
        case let (type1, .Optional(type2)):
            if case let .Optional(type1) = type1 {
                return .Optional(type1.mergeWith(type2))
            } else {
                return .Optional(type1.mergeWith(type2))
            }
        case let (.Unknown, knownType):
            return knownType
        case let (knownType, .Unknown):
            return knownType
        case let (.Number(numberType1), .Number(numberType2)) where numberType1.mergeWith(numberType2) != nil:
            let mergedNumberType = numberType1.mergeWith(numberType2)!
            return .Number(mergedNumberType)
        case let (.Object(fields1), .Object(fields2)):
            var resultFields: Set<ModelParser.ObjectField> = []
            var remainingFields = fields2
            for f1 in fields1 {
                let foundItemIndex = remainingFields.indexOf { f -> Bool in
                    return f1.name == f.name
                }
                let field: ModelParser.ObjectField
                if let foundItemIndex = foundItemIndex {
                    let foundItem = remainingFields.removeAtIndex(foundItemIndex)
                    let mergedType = f1.type.mergeWith(foundItem.type)
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
            return .List(listType1.mergeWith(listType2))
        case let (.Enum(enumTypes), type):
            return .Enum(mergeEnumTypes(enumTypes, otherType: type))
        case let (type, .Enum(enumTypes)):
            return .Enum(mergeEnumTypes(enumTypes, otherType: type))
        default:
            return .Enum([self, type])
        }
    }
}


