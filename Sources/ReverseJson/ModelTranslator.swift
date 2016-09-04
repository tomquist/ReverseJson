
public protocol ModelTranslator {
    init(args: [String])
    func translate(_ type: FieldType, name: String) -> String
}

