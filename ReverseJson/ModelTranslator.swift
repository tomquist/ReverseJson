
public protocol ModelTranslator {
    init(args: [String])
    func translate(type: ModelParser.FieldType, name: String) -> String
}

