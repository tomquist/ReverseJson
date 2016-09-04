
public enum JSON {
    case null
    case bool(Bool)
    case number(JSONNumber)
    case string(String)
    case array([JSON])
    case object([String: JSON])
}

public enum JSONNumber {
    case int(Int)
    case uint(UInt)
    case float(Float)
    case double(Double)
}

extension JSON: Equatable {
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case let (.bool(bool1), .bool(bool2)): return bool1 == bool2
        case let (.number(number1), .number(number2)): return number1 == number2
        case let (.string(string1), .string(string2)): return string1 == string2
        case let (.array(array1), .array(array2)): return array1 == array2
        case let (.object(object1), .object(object2)): return object1 == object2
        default: return false
        }
    }
}

extension JSONNumber: Equatable {
    public static func ==(lhs: JSONNumber, rhs: JSONNumber) -> Bool {
        switch (lhs, rhs) {
        case let (.int(int1), .int(int2)): return int1 == int2
        case let (.uint(uint1), .uint(uint2)): return uint1 == uint2
        case let (.float(float1), .float(float2)): return float1 == float2
        case let (.double(double1), .double(double2)): return double1 == double2
        default: return false
        }
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(.int(value))
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(.double(value))
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(elements.reduce([:]) { (dict, tuple) -> [String: JSON] in
            var dict = dict
            dict[tuple.0] = tuple.1
            return dict
        })
    }
}

public protocol JSONTransformer {
    associatedtype Input
    
    /// Transforms the given value into JSON
    func transform(_ value: Input) throws -> JSON
    
}
