import Foundation

extension FieldType {
    public var enumCaseName: String {
        switch self {
        case .object: return "object"
        case .list: return "list"
        case .text: return "text"
        case .number(.bool): return "boolean"
        case .number: return "number"
        case .enum: return "enum"
        case .unknown: return "unknownType"
        case let .optional(type): return type.enumCaseName
        }
    }
}


extension String {
    
    public init(lines: String...) {
        self = lines.joined(separator: "\n")
    }
    
    public init(joined parts: [String], separator: String = "\n") {
        self = parts.joined(separator: separator)
    }
    
    public func times(_ times: Int) -> String {
        return String(joined: (0..<times).lazy.map { _ -> String in
            return self
        }, separator: "")
    }
    
    public func indent(_ level: Int, spaces: Int = 4) -> String {
        let suffix = self.hasSuffix("\n") ? "\n" : ""
        let indented = String(joined: self.split(separator: "\n").lazy.map { " ".times(level * spaces) + String($0) })
        return indented + suffix
    }
    public func firstCapitalized() -> String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
    public func firstLowercased() -> String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).lowercased())
        return result
    }
    
    public func pascalCased() -> String {
        let slices = self.split { $0 == "_" || $0 == " " }
        if let first = slices.first {
            return slices.dropFirst().reduce(String(first)) { (string, subSequence) in
                return string + String(subSequence[subSequence.startIndex]).uppercased() + String(subSequence.suffix(from: subSequence.index(subSequence.startIndex, offsetBy: 1)))
                }.firstLowercased()
        }
        return self
    }
    public var camelCasedString: String {
        return self.pascalCased().firstCapitalized()
    }
    
    
    static let swiftKeywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "func", "import", "init", "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "Any", "catch", "dynamicType", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix", "indirect", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "Type", "unowned", "weak", "willSet"
    ]
    
    static let objcKeywords: Set<String> = [
        "description", "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "_Bool", "_Complex", "_Imaginery"
    ]
    
    public var swiftKeywordEscaped: String {
        if String.swiftKeywords.contains(self) {
            return "`\(self)`"
        } else {
            return self
        }
    }
    
    
    public var asValidSwiftIdentifier: String {
        if let identifierHead = first {
            let head: String
            let identifierTail = suffix(from: index(after: startIndex))
            let tail = String(joined: identifierTail.split(whereSeparator: { !$0.isValidSwiftIdentifierTailCharacter}).map(String.init), separator: "_").pascalCased()
            if identifierHead.isValidSwiftIdentifierHeadCharacter {
                head = String(identifierHead)
            } else {
                head = tail.isEmpty || !tail.first!.isValidSwiftIdentifierHeadCharacter ? "_" : ""
            }
            return "\(head)\(tail)"
        } else {
            return "_"
        }
    }
    
    public var asValidObjcIdentifier: String {
        guard !String.objcKeywords.contains(self) && self != "signed" && !self.hasPrefix("new") && !self.hasPrefix("copy") && !self.hasPrefix("init") else {
            return "$\(self)"
        }
        return self
    }
}

extension Character {

    private static let tailCharRanges = Character.headCharRanges + [
        0x30...0x39, // decimal
        0x300...0x36F,
        0x1DC0...0x1DFF,
        0x20D0...0x20FF,
        0xFE20...0xFE2F,
    ]
    
    private static let headCharRanges: [ClosedRange<UInt32>] = [
        0x41...0x5A as ClosedRange<UInt32>, // uppercase
        0x61...0x7A as ClosedRange<UInt32>, // lowercase
        0xA8...0xA8 as ClosedRange<UInt32>,
        0xAA...0xAA as ClosedRange<UInt32>,
        0xAD...0xAD as ClosedRange<UInt32>,
        0xAF...0xAF as ClosedRange<UInt32>,
        0xB2...0xB5 as ClosedRange<UInt32>,
        0xB7...0xBA as ClosedRange<UInt32>,
        0xBC...0xBE as ClosedRange<UInt32>,
        0xC0...0xD6 as ClosedRange<UInt32>,
        0xD8...0xF6 as ClosedRange<UInt32>,
        0xF8...0xFF as ClosedRange<UInt32>,
        0x100...0x2FF as ClosedRange<UInt32>,
        0x370...0x167F as ClosedRange<UInt32>,
        0x1681...0x180D as ClosedRange<UInt32>,
        0x180F...0x1DBF as ClosedRange<UInt32>,
        0x1E00...0x1FFF as ClosedRange<UInt32>,
        0x200B...0x200D as ClosedRange<UInt32>,
        0x202A...0x202E as ClosedRange<UInt32>,
        0x203F...0x2040 as ClosedRange<UInt32>,
        0x2054...0x2054 as ClosedRange<UInt32>,
        0x2060...0x206F as ClosedRange<UInt32>,
        0x2070...0x20CF as ClosedRange<UInt32>,
        0x2100...0x218F as ClosedRange<UInt32>,
        0x2460...0x24FF as ClosedRange<UInt32>,
        0x2776...0x2793 as ClosedRange<UInt32>,
        0x2C00...0x2DFF as ClosedRange<UInt32>,
        0x2E80...0x2FFF as ClosedRange<UInt32>,
        0x3004...0x3007 as ClosedRange<UInt32>,
        0x3021...0x302F as ClosedRange<UInt32>,
        0x3031...0x303F as ClosedRange<UInt32>,
        0x3040...0xD7FF as ClosedRange<UInt32>,
        0xF900...0xFD3D as ClosedRange<UInt32>,
        0xFD40...0xFDCF as ClosedRange<UInt32>,
        0xFDF0...0xFE1F as ClosedRange<UInt32>,
        0xFE30...0xFE44 as ClosedRange<UInt32>,
        0xFE47...0xFFFD as ClosedRange<UInt32>,
        0x10000...0x1FFFD as ClosedRange<UInt32>,
        0x20000...0x2FFFD as ClosedRange<UInt32>,
        0x30000...0x3FFFD as ClosedRange<UInt32>,
        0x40000...0x4FFFD as ClosedRange<UInt32>,
        0x50000...0x5FFFD as ClosedRange<UInt32>,
        0x60000...0x6FFFD as ClosedRange<UInt32>,
        0x70000...0x7FFFD as ClosedRange<UInt32>,
        0x80000...0x8FFFD as ClosedRange<UInt32>,
        0x90000...0x9FFFD as ClosedRange<UInt32>,
        0xA0000...0xAFFFD as ClosedRange<UInt32>,
        0xB0000...0xBFFFD as ClosedRange<UInt32>,
        0xC0000...0xCFFFD as ClosedRange<UInt32>,
        0xD0000...0xDFFFD as ClosedRange<UInt32>,
        0xE0000...0xEFFFD as ClosedRange<UInt32>
    ]
    
    var isValidSwiftIdentifierHeadCharacter: Bool {
        return !String(self).utf16.flatMap(UnicodeScalar.init).map { scalar -> Bool in
            return Character.headCharRanges.contains { range in
                range.contains(scalar.value)
            }
        }.contains(false)
    }
    
    var isValidSwiftIdentifierTailCharacter: Bool {
        return !String(self).utf16.flatMap(UnicodeScalar.init).map { scalar -> Bool in
            return Character.tailCharRanges.contains { range in
                range.contains(scalar.value)
            }
        }.contains(false)
    }
    
}
