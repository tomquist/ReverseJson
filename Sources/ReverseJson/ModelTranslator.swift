
public protocol ModelTranslator {
    init(args: [String])
    func translate(_ type: ModelParser.FieldType, name: String) -> String
}

