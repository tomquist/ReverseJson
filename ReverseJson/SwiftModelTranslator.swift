import Foundation

public class SwiftModelCreator: ModelTranslator {
    
    public init() {}
    public func translate(type: ModelParser.FieldType, name: String) -> String {
        return type.toModel(name)
    }
    
}

extension ModelParser.FieldType {
    private func toModel(name: String) -> String {
        let (typeName, decl) = self.makeSubtype("", subName: name, level: 0)
        if let decl = decl {
            return decl
        } else {
            return "typealias \(name) = \(typeName)\n"
        }
    }
    
    private func makeSubtype(name: String, subName: String, level: Int) -> (name: String, declaration: String?) {
        let fieldType: String
        let declaration: String?
        switch self {
        case let .Object(fields):
            fieldType = "\(subName.camelCasedString)"
            declaration = createStructDeclaration(fieldType, fields: fields, level: level)
        case let .Number(numberType):
            fieldType = numberType.rawValue
            declaration = nil
        case .Text:
            fieldType = "String"
            declaration = nil
        case let .List(listItemType):
            let (subTypeName, subDeclaration) = listItemType.makeSubtype("\(name)\(subName.camelCasedString)", subName: "\(subName)Item", level: level)
            declaration = subDeclaration
            fieldType = "[\(subTypeName)]"
        case let .Enum(enumTypes):
            fieldType = "\(subName.camelCasedString)"
            declaration = createEnumDeclaration(fieldType, cases: enumTypes, level: level)
        case let .Optional(type):
            let (subTypeName, subDeclaration) = type.makeSubtype(name, subName: subName, level: level)
            declaration = subDeclaration
            fieldType = "\(subTypeName)?"
        case .Unknown:
            fieldType = subName.camelCasedString
            declaration = "typealias \(fieldType) = Void".indent(level)
        }
        return (fieldType, declaration)
    }
    
    private func createStructDeclaration(name: String, fields: [ModelParser.ObjectField], level: Int = 0) -> String {
        var ret = "struct \(name) {\n".indent(level)
        let fieldsAndTypes = fields.map { f -> (field: String, type: String?) in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = f.type.makeSubtype(name, subName: f.name, level: level + 1)
            fieldDeclaration += ("let \(f.name.pascalCasedString.swiftKeywordEscaped): \(typeName)")
            return (fieldDeclaration, subTypeDeclaration)
        }
        ret += Set(fieldsAndTypes.lazy.flatMap { $0.type.map({"\($0)\n"})}).sort(<).joinWithSeparator("")
        ret += fieldsAndTypes.lazy.map { $0.field.indent(level + 1) }.sort { $0.0.localizedStandardCompare($0.1) == .OrderedAscending }.joinWithSeparator("\n") + "\n"
        return ret + "}".indent(level)
    }
    
    private func createEnumDeclaration(name: String, cases: [ModelParser.FieldType], level: Int = 0) -> String {
        var ret = "enum \(name) {\n".indent(level)
        ret += cases.map { c -> String in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = c.makeSubtype(name, subName: "\(name)\(c.enumCaseName)", level: level + 1)
            if let subTypeDeclaration = subTypeDeclaration {
                fieldDeclaration += "\n" + subTypeDeclaration + "\n"
            }
            fieldDeclaration += "case \(c.enumCaseName)(\(typeName))".indent(level + 1)
            return fieldDeclaration
        }.joinWithSeparator("\n")
        return ret + "\n" + "}".indent(level)
    }
    
    
}


private struct Declaration: Hashable {
    let text: String
    let priority: Int
    init(text: String, priority: Int = 100) {
        self.text = text
        self.priority = priority
    }
    var hashValue: Int {
        return text.hashValue
    }
}
private func ==(lhs: Declaration, rhs: Declaration) -> Bool {
    return lhs.text == rhs.text
}
extension Declaration : StringLiteralConvertible {
    init(stringLiteral value: String) {
        self = Declaration(text: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self = Declaration(text: value)
    }
    init(unicodeScalarLiteral value: String) {
        self = Declaration(text: value)
    }
}

public class SwiftJsonParsingTranslator: ModelTranslator {
    public func translate(type: ModelParser.FieldType, name: String) -> String {
        let (parsers, instructions, typeName) = type.createParsers([name], valueExpression: "jsonValue")
        
        let declarations = parsers.sort { $0.0.priority > $0.1.priority }.lazy.map { $0.text }.joinWithSeparator("\n\n")
        let parseFunction = [
            "",
            "",
            "func parse\(name.camelCasedString)(jsonValue: AnyObject?) throws -> \(typeName) {",
            "    return \(instructions)",
            "}",
        ].joinWithSeparator("\n")
        return declarations + parseFunction
    }
    
    

}
extension ModelParser.FieldType {
    
    private static let errorTypeDeclaration = Declaration(text: [
        "enum JsonParsingError: ErrorType {",
        "    case UnsupportedTypeError",
        "}"
    ].joinWithSeparator("\n"), priority: 1000)
    
    private static let arrayParserDeclaration = Declaration(text: [
        "extension Array {",
        "    init(jsonValue: AnyObject?, map: AnyObject throws -> Element) throws {",
        "        if let items = jsonValue as? [AnyObject] {",
        "            self = try items.map(map)",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}",
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let stringParserDeclaration = Declaration(text: [
        "extension String {",
        "    init(jsonValue: AnyObject?) throws {",
        "        if let string = jsonValue as? String {",
        "            self = string",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let boolParserDeclaration = Declaration(text: [
        "extension Bool {",
        "    init(jsonValue: AnyObject?) throws {",
        "        if let number = jsonValue as? NSNumber {",
        "            self = number.boolValue",
        "        } else if let number = jsonValue as? Bool {",
        "            self = number",
        "        } else if let number = jsonValue as? Double {",
        "            self = Bool(number)",
        "        } else if let number = jsonValue as? Float {",
        "            self = Bool(number)",
        "        } else if let number = jsonValue as? Int {",
        "            self = Bool(number)",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let intParserDeclaration = Declaration(text: [
        "extension Int {",
        "    init(jsonValue: AnyObject?) throws {",
        "        if let number = jsonValue as? NSNumber {",
        "            self = number.integerValue",
        "        } else if let number = jsonValue as? Int {",
        "            self = number",
        "        } else if let number = jsonValue as? Double {",
        "            self = Int(number)",
        "        } else if let number = jsonValue as? Float {",
        "            self = Int(number)",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let floatParserDeclaration = Declaration(text: [
        "extension Float {",
        "    init(jsonValue: AnyObject?) throws {",
        "        if let number = jsonValue as? NSNumber {",
        "            self = number.floatValue",
        "        } else if let number = jsonValue as? Int {",
        "            self = Float(number)",
        "        } else if let number = jsonValue as? Double {",
        "            self = Float(number)",
        "        } else if let number = jsonValue as? Float {",
        "            self = number",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let doubleParserDeclaration = Declaration(text: [
        "extension Double {",
        "    init(jsonValue: AnyObject?) throws {",
        "        if let number = jsonValue as? NSNumber {",
        "            self = number.doubleValue",
        "        } else if let number = jsonValue as? Int {",
        "            self = Double(number)",
        "        } else if let number = jsonValue as? Double {",
        "            self = number",
        "        } else if let number = jsonValue as? Float {",
        "            self = Double(number)",
        "        } else {",
        "            throw JsonParsingError.UnsupportedTypeError",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority: 500)
    
    private static let optionalParserDeclaration = Declaration(text: [
        "extension Optional {",
        "    init(jsonValue: AnyObject?, map: AnyObject throws -> Wrapped) throws {",
        "        if let jsonValue = jsonValue where !(jsonValue is NSNull) {",
        "            self = try map(jsonValue)",
        "        } else {",
        "            self = nil",
        "        }",
        "    }",
        "}"
    ].joinWithSeparator("\n"), priority:  500)
    
    private func createParser(numberType: ModelParser.NumberType, valueExpression: String, tryOptional: Bool) -> (parserDeclarations: Set<Declaration>, parsingInstruction: String, typeName: String) {
        let parser: Declaration
        let instruction: String
        let typeName: String
        let tryOptionalModifier = tryOptional ? "?" : ""
        switch numberType {
        case .Bool:
            parser = ModelParser.FieldType.boolParserDeclaration
            instruction = "try\(tryOptionalModifier) Bool(jsonValue: \(valueExpression))"
            typeName = "Bool"
        case .Int:
            parser = ModelParser.FieldType.intParserDeclaration
            instruction = "try\(tryOptionalModifier) Int(jsonValue: \(valueExpression))"
            typeName = "Int"
        case .Float:
            parser = ModelParser.FieldType.floatParserDeclaration
            instruction = "try\(tryOptionalModifier) Float(jsonValue: \(valueExpression))"
            typeName = "Float"
        case .Double:
            parser = ModelParser.FieldType.doubleParserDeclaration
            instruction = "try\(tryOptionalModifier) Double(jsonValue: \(valueExpression))"
            typeName = "Double"
        }
        return ([ModelParser.FieldType.errorTypeDeclaration, parser], instruction, typeName)
    }
    
    
    
    private func createParsers(parentTypeNames: [String], valueExpression: String, tryOptional: Bool = false) -> (parserDeclarations: Set<Declaration>, parsingInstruction: String, typeName: String) {
        let tryOptionalModifier = tryOptional ? "?" : ""
        switch self {
        case let .Number(numberType):
            return createParser(numberType, valueExpression: valueExpression, tryOptional: tryOptional)
        case .Text:
            return ([ModelParser.FieldType.stringParserDeclaration], "try\(tryOptionalModifier) String(jsonValue: \(valueExpression))", "String")
        case let .List(listType):
            var childTypeNames = parentTypeNames
            if let last = childTypeNames.last {
                childTypeNames.removeLast()
                childTypeNames.append("\(last)Item")
            }
            let (subDeclarations, instruction, typeName) = listType.createParsers(childTypeNames, valueExpression: "$0")
            let declarations = subDeclarations.union([ModelParser.FieldType.errorTypeDeclaration, ModelParser.FieldType.arrayParserDeclaration])
            return (declarations, "try\(tryOptionalModifier) Array(jsonValue: \(valueExpression)) { \(instruction) }", "[\(typeName)]")
        case .Optional(.Unknown):
            return ([], "nil", parentTypeNames.joinWithSeparator("."))
        case let .Optional(optionalType):
            let (subDeclarations, instruction, typeName) = optionalType.createParsers(parentTypeNames, valueExpression: "$0")
            return (subDeclarations.union([ModelParser.FieldType.errorTypeDeclaration, ModelParser.FieldType.optionalParserDeclaration]), "try\(tryOptionalModifier) Optional(jsonValue: \(valueExpression)) { \(instruction) }", "\(typeName)?")
        case let .Object(fields):
            var declarations = Set<Declaration>()
            let typeName = parentTypeNames.joinWithSeparator(".")
            var parser = [
                "extension \(typeName) {",
                "    init(jsonValue: AnyObject?) throws {",
                "        if let dict = jsonValue as? [NSObject: AnyObject] {\n"
            ].joinWithSeparator("\n")
            parser += fields.map { field in
                let (subDeclarations, instruction, _) = field.type.createParsers(parentTypeNames + [field.name.camelCasedString], valueExpression: "dict[\"\(field.name)\"]")
                declarations.unionInPlace(subDeclarations)
                return "self.\(field.name.pascalCasedString.swiftKeywordEscaped) = \(instruction)".indent(3)
                }.joinWithSeparator("\n") + "\n"
            parser += [
                "        } else {",
                "            throw JsonParsingError.UnsupportedTypeError",
                "        }",
                "    }",
                "}"
            ].joinWithSeparator("\n")
            declarations.insert(Declaration(text: parser))
            return (declarations, "try\(tryOptionalModifier) \(typeName)(jsonValue: \(valueExpression))", typeName)
        case let .Enum(types):
            var declarations = Set<Declaration>()
            let typeName = parentTypeNames.joinWithSeparator(".")
            var parser = [
                "extension \(typeName) {",
                "    init(jsonValue: AnyObject?) throws {",
                "        ",
            ].joinWithSeparator("\n")
            parser += types.map { (type: ModelParser.FieldType) -> String in
                let (subDeclarations, instruction, _) = type.createParsers(parentTypeNames + ["\(parentTypeNames.last!)\(type.enumCaseName)"], valueExpression: "jsonValue", tryOptional: true)
                declarations.unionInPlace(subDeclarations)
                return [
                    "if let value = \(instruction) {",
                    "            self = \(type.enumCaseName)(value)",
                    "        }",
                ].joinWithSeparator("\n")
            }.joinWithSeparator(" else ")
            parser += [" else {",
                "            throw JsonParsingError.UnsupportedTypeError",
                "        }",
                "    }",
                "}",
            ].joinWithSeparator("\n")
            declarations.insert(Declaration(text: parser))
            return (declarations, "try\(tryOptionalModifier) \(typeName)(jsonValue: \(valueExpression))", typeName)
        case .Unknown:
            return ([], "nil", parentTypeNames.joinWithSeparator("."))
        }
        
    }
    
}