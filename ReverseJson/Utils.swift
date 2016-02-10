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
    
    
    public var asValidSwiftIdentifier: String {
        let chars = self.characters
        if let identifierHead = chars.first {
            let head: String
            let identifierTail = chars.suffixFrom(chars.startIndex.successor())
            let tail = identifierTail.split(isSeparator: NSCharacterSet.swiftIdentifierValidTailChars.invertedSet.characterIsMember).map(String.init).joinWithSeparator("_").pascalCasedString
            if NSCharacterSet.swiftIdentifierValidHeadChars.characterIsMember(identifierHead) {
                head = String(identifierHead)
            } else {
                head = tail.isEmpty || !NSCharacterSet.swiftIdentifierValidHeadChars.characterIsMember(tail.characters.first!) ? "_" : ""
            }
            return "\(head)\(tail)"
        } else {
            return "_"
        }
    }
}

extension NSCharacterSet {
    private static let swiftIdentifierValidHeadChars: NSCharacterSet = {
        let ranges: [NSRange] = [
            .init(location: 0xA8, length: 1),
            .init(location: 0xAA, length: 1),
            .init(location: 0xAD, length: 1),
            .init(location: 0xAF, length: 1),
            .init(location: 0xB2, length: 0xB5-0xB2),
            .init(location: 0xB7, length: 0xBA-0xB7),
            .init(location: 0xBC, length: 0xBE-0xBC),
            .init(location: 0xC0, length: 0xD6-0xC0),
            .init(location: 0xD8, length: 0xF6-0xD8),
            .init(location: 0xF8, length: 0xFF-0xF8),
            .init(location: 0x100, length: 0x2FF-0x100),
            .init(location: 0x370, length: 0x167F-0x370),
            .init(location: 0x1681, length: 0x180D-0x1681),
            .init(location: 0x180F, length: 0x1DBF-0x180F),
            .init(location: 0x1E00, length: 0x1FFF-0x1E00),
            .init(location: 0x200B, length: 0x200D-0x200B),
            .init(location: 0x202A, length: 0x202E-0x202A),
            .init(location: 0x203F, length: 0x2040-0x203F),
            .init(location: 0x2054, length: 1),
            .init(location: 0x2060, length: 0x206F-0x2060),
            .init(location: 0x2070, length: 0x20CF-0x2070),
            .init(location: 0x2100, length: 0x218F-0x2100),
            .init(location: 0x2460, length: 0x24FF-0x2460),
            .init(location: 0x2776, length: 0x2793-0x2776),
            .init(location: 0x2C00, length: 0x2DFF-0x2C00),
            .init(location: 0x2E80, length: 0x2FFF-0x2E80),
            .init(location: 0x3004, length: 0x3007-0x3004),
            .init(location: 0x3021, length: 0x302F-0x3021),
            .init(location: 0x3031, length: 0x303F-0x3031),
            .init(location: 0x3040, length: 0xD7FF-0x3040),
            .init(location: 0xF900, length: 0xFD3D-0xF900),
            .init(location: 0xFD40, length: 0xFDCF-0xFD40),
            .init(location: 0xFDF0, length: 0xFE1F-0xFDF0),
            .init(location: 0xFE30, length: 0xFE44-0xFE30),
            .init(location: 0xFE47, length: 0xFFFD-0xFE47),
            .init(location: 0x10000, length: 0x1FFFD-0x10000),
            .init(location: 0x20000, length: 0x2FFFD-0x20000),
            .init(location: 0x30000, length: 0x3FFFD-0x30000),
            .init(location: 0x40000, length: 0x4FFFD-0x40000),
            .init(location: 0x50000, length: 0x5FFFD-0x50000),
            .init(location: 0x60000, length: 0x6FFFD-0x60000),
            .init(location: 0x70000, length: 0x7FFFD-0x70000),
            .init(location: 0x80000, length: 0x8FFFD-0x80000),
            .init(location: 0x90000, length: 0x9FFFD-0x90000),
            .init(location: 0xA0000, length: 0xAFFFD-0xA0000),
            .init(location: 0xB0000, length: 0xBFFFD-0xB0000),
            .init(location: 0xC0000, length: 0xCFFFD-0xC0000),
            .init(location: 0xD0000, length: 0xDFFFD-0xD0000),
            .init(location: 0xE0000, length: 0xEFFFD-0xE0000)
        ]
        let charset: NSMutableCharacterSet = .uppercaseLetterCharacterSet()
        charset.formUnionWithCharacterSet(.lowercaseLetterCharacterSet())
        charset.addCharactersInString("_")
        return ranges.reduce(charset) {
            $0.0.addCharactersInRange($0.1)
            return $0.0
        }
    }()
    
    private static let swiftIdentifierValidTailChars: NSCharacterSet = {
        let ranges: [NSRange] = [
            .init(location: 0x300, length: 0x36F-0x300),
            .init(location: 0x1DC0, length: 0x1DFF-0x1DC0),
            .init(location: 0x20D0, length: 0x20FF-0x20D0),
            .init(location: 0xFE20, length: 0xFE2F-0xFE20),
        ]
        let charset: NSMutableCharacterSet = .decimalDigitCharacterSet()
        charset.formUnionWithCharacterSet(.swiftIdentifierValidHeadChars)
        return ranges.reduce(charset) {
            $0.0.addCharactersInRange($0.1)
            return $0.0
        }
    }()
    
    func characterIsMember(char: Character) -> Bool {
        for codeUnit in String(char).utf16 {
            if !characterIsMember(codeUnit) {
                return false
            }
        }
        return true
    }
}
