import Foundation

public protocol ModelTranslator {
    func translate(type: ModelParser.FieldType, name: String) -> String
}

