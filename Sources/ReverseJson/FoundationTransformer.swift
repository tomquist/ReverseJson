import Foundation

/// Transforms output of Foundations JSONSerialization into JSON
public struct FoundationJSONTransformer: JSONTransformer {
    
    public enum TransformationError: Error {
        case unsupportedValueType(Any, Any.Type)
    }
    
    private func transform(_ object: [String: Any]) throws -> [String: JSON] {
        var result = [String: JSON]()
        try object.forEach { (key, value) in
            result[key] = try transform(value)
        }
        return result
    }
    
    public func transform(_ value: Any) throws -> JSON {
        switch value {
        case let optional as OptionalType where optional.isNil:
            return .null
        case let string as String:
            return .string(string)
        case let number as BoolConvertible where number.asBool != nil:
            return .bool(number.asBool!)
        case let number as NSNumber where value is Double: // Only on ios/osx we can bridge numbers to double and NSNumber
            return number.json
        case let float as Float:
            return .number(.float(float))
        case let double as Double:
            return .number(.double(double))
        case let uint as UInt:
            return .number(.uint(uint))
        case let int as Int:
            return .number(.int(int))
        case let number as NSNumber:
            return number.json
        case let object as [String: Any]:
            return .object(try transform(object))
        case let array as [Any]:
            return .array(try array.map(transform))
        default:
            throw TransformationError.unsupportedValueType(value, type(of: value))
        }
    }
}

extension NSNumber {
    
    private static let trueNumber = NSNumber(value: true)
    private static let falseNumber = NSNumber(value: false)
    private static let trueObjCType = String(cString: NSNumber.trueNumber.objCType)
    private static let falseObjCType = String(cString: NSNumber.falseNumber.objCType)
    
    fileprivate var isBool:Bool {
        get {
            #if !os(Linux)
            let objCType = String(cString: self.objCType)
            if (self.compare(NSNumber.trueNumber) == .orderedSame && objCType == NSNumber.trueObjCType)
                || (self.compare(NSNumber.falseNumber) == ComparisonResult.orderedSame && objCType == NSNumber.falseObjCType){
                return true
            }
            #endif
            return false
        }
    }

    fileprivate var json: JSON {
        if isBool {
            return .bool(boolValue)
        }
        #if !os(Linux)
        if let objcType = String(validatingUTF8: self.objCType)?.lowercased() {
            switch objcType {
            case "b", "c": return .bool(boolValue)
            case "i", "l", "q": return .number(.int(intValue))
            case "f": return .number(.float(floatValue))
            case "d": return .number(.double(doubleValue))
            default: break
            }
        }
        #endif
        return .number(.double(doubleValue))
    }
}

/// Types that can potentially be converted into Bool
fileprivate protocol BoolConvertible {
    var asBool: Bool? { get }
}


extension NSNumber: BoolConvertible {
        
    fileprivate var asBool: Bool? {
        switch json {
        case let .bool(bool): return bool
        default: return nil
        }
    }
    
}

extension Bool: BoolConvertible {
    var asBool: Bool? {
        return self
    }
}

fileprivate protocol OptionalType {
    var isNil: Bool { get }
}

extension Optional: OptionalType {
    fileprivate var isNil: Bool {
        if case .none = self {
            return true
        }
        return false
    }
}

extension NSNull: OptionalType {
    fileprivate var isNil: Bool {
        return true
    }
}
