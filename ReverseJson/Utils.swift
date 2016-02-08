import Foundation



extension ModelParser.FieldType {
    public var enumCaseName: String {
        switch self {
        case .Object: return "Object"
        case .List: return "List"
        case .Text: return "Text"
        case .Number(.Bool): return "Boolean"
        case .Number: return "Number"
        case .Enum: return "Enum"
        case .Unknown: return "UnknownType"
        case let .Optional(type): return "Optional\(type.enumCaseName)"
        }
    }
}


extension String {
    
    public func times(times: Int) -> String {
        return (0..<times).lazy.map { _ -> String in
            return self
            }.joinWithSeparator("")
    }
    
    public func indent(level: Int, spaces: Int = 4) -> String {
        let suffix = self.hasSuffix("\n") ? "\n" : ""
        let indented = self.characters.split("\n").lazy.map { " ".times(level * spaces) + String($0) }.joinWithSeparator("\n")
        return indented + suffix
    }
    public var firstCapitalizedString: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).uppercaseString)
        return result
    }
    public var firstLowercasedString: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).lowercaseString)
        return result
    }
    
    public var pascalCasedString: String {
        let slices = self.characters.split { $0 == "_" || $0 == " " }
        if let first = slices.first {
            return slices.dropFirst().reduce(String(first)) { (string, subSequence) in
                return string + String(subSequence[subSequence.startIndex]).uppercaseString + String(subSequence.suffixFrom(subSequence.startIndex.advancedBy(1)))
                }.firstLowercasedString
        }
        return self
    }
    public var camelCasedString: String {
        return self.pascalCasedString.firstCapitalizedString
    }
    
    
    static let swiftKeywords: Set<String> = [
        "class", "deinit", "enum", "extension", "func", "import", "init", "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "catch", "dynamicType", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "__COLUMN__", "__FILE__", "__FUNCTION__",  "__LINE__", "_", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "indirect", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "Type", "unowned", "weak", "willSet"
    ]
    
    public var swiftKeywordEscaped: String {
        if String.swiftKeywords.contains(self) {
            return "`\(self)`"
        } else {
            return self
        }
    }
}
