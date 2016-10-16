
public struct TranslatorOutput {
    public var name: String
    public var content: String
    
    public init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}
extension TranslatorOutput: Hashable {
    public var hashValue: Int {
        return 17 &+ content.hashValue &* 37 &+ name.hashValue
    }
    public static func ==(lhs: TranslatorOutput, rhs: TranslatorOutput) -> Bool {
        return lhs.name == rhs.name && lhs.content == rhs.content
    }
}

public protocol ModelTranslator {
    func translate(_ type: FieldType, name: String) -> [TranslatorOutput]
}

extension ModelTranslator {
    public func translate(_ type: FieldType, name: String, outputFormatter: (TranslatorOutput) -> String = {"// \($0.name)\n\($0.content)"}) -> String {
        let files: [TranslatorOutput] = translate(type, name: name)
        return files.map(outputFormatter).joined(separator: "\n")
    }
}
