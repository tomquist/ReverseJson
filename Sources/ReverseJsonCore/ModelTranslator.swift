
public protocol ModelTranslator {
    func translate(_ type: FieldType, name: String) -> String
}
