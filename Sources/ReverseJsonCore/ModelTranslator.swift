
public struct TranslatorOutput: Hashable, Equatable {
    public var name: String
    public var content: String
    
    public init(name: String, content: String) {
        self.name = name
        self.content = content
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
