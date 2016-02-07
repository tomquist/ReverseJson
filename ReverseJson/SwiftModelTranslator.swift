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
            let (subTypeName, subDeclaration) = listItemType.makeSubtype("\(name)\(subName.camelCasedString)", subName: subName, level: level)
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
            fieldType = "UnknownType"
            declaration = nil
        }
        return (fieldType, declaration)
    }
    
    private func createStructDeclaration(name: String, fields: [ModelParser.ObjectField], level: Int = 0) -> String {
        var ret = "struct \(name) {\n".indent(level)
        ret += fields.map { f -> String in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = f.type.makeSubtype(name, subName: f.name, level: level + 1)
            if let subTypeDeclaration = subTypeDeclaration {
                fieldDeclaration += "\n" + subTypeDeclaration + "\n"
            }
            fieldDeclaration += ("let \(f.name.pascalCasedString.swiftKeywordEscaped): \(typeName)").indent(level + 1)
            return fieldDeclaration
        }.joinWithSeparator("\n")
        return ret + "\n" + "}".indent(level)
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


public class SwiftJsonParsingTranslator: ModelTranslator {
    public func translate(type: ModelParser.FieldType, name: String) -> String {
        let (parsers, instructions, typeName) = type.createParsers([name], valueExpression: "jsonValue")
        return parsers.joinWithSeparator("\n") + "\n" + "func parse\(name.camelCasedString)(jsonValue: AnyObject?) throws -> \(typeName) {\n"
            + "return \(instructions)\n".indent(1)
            + "}\n"
    }
}
extension ModelParser.FieldType {
    private static let errorTypeDeclaration = "enum JsonParsingError: ErrorType {\n"
        + "case UnsupportedTypeError\n".indent(1)
        + "}"
    private static let stringParserDeclaration = "extension String {\n"
        + "init(jsonValue: AnyObject?) throws {\n".indent(1)
        + "if let string = jsonValue as? String {\n".indent(2)
        + "self = string\n".indent(3)
        + "} else {\n".indent(2)
        + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
        + "}\n".indent(2)
        + "}\n".indent(1)
        + "}\n"
    private static let boolParserDeclaration = "extension Bool {\n"
        + "init(jsonValue: AnyObject?) throws {\n".indent(1)
        + "if let number = jsonValue as? NSNumber {\n".indent(2)
        + "self = number.boolValue\n".indent(3)
        + "} else if let number = jsonValue as? Bool {\n".indent(2)
        + "self = number\n".indent(3)
        + "} else if let number = jsonValue as? Double {\n".indent(2)
        + "self = Bool(number)\n".indent(3)
        + "} else if let number = jsonValue as? Float {\n".indent(2)
        + "self = Bool(number)\n".indent(3)
        + "} else if let number = jsonValue as? Int {\n".indent(2)
        + "self = Bool(number)\n".indent(3)
        + "} else {\n".indent(2)
        + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
        + "}\n".indent(2)
        + "}\n".indent(1)
        + "}\n"
    private static let intParserDeclaration = "extension Int {\n"
        + "init(jsonValue: AnyObject?) throws {\n".indent(1)
        + "if let number = jsonValue as? NSNumber {\n".indent(2)
        + "self = number.integerValue\n".indent(3)
        + "} else if let number = jsonValue as? Int {\n".indent(2)
        + "self = number\n".indent(3)
        + "} else if let number = jsonValue as? Double {\n".indent(2)
        + "self = Int(number)\n".indent(3)
        + "} else if let number = jsonValue as? Float {\n".indent(2)
        + "self = Int(number)\n".indent(3)
        + "} else {\n".indent(2)
        + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
        + "}\n".indent(2)
        + "}\n".indent(1)
        + "}\n"
    private static let floatParserDeclaration = "extension Float {\n"
        + "init(jsonValue: AnyObject?) throws {\n".indent(1)
        + "if let number = jsonValue as? NSNumber {\n".indent(2)
        + "self = number.floatValue\n".indent(3)
        + "} else if let number = jsonValue as? Int {\n".indent(2)
        + "self = Float(number)\n".indent(3)
        + "} else if let number = jsonValue as? Double {\n".indent(2)
        + "self = Float(number)\n".indent(3)
        + "} else if let number = jsonValue as? Float {\n".indent(2)
        + "self = number\n".indent(3)
        + "} else {\n".indent(2)
        + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
        + "}\n".indent(2)
        + "}\n".indent(1)
        + "}\n"
    private static let doubleParserDeclaration = "extension Int {\n"
        + "init(jsonValue: AnyObject?) throws {\n".indent(1)
        + "if let number = jsonValue as? NSNumber {\n".indent(2)
        + "self = number.doubleValue\n".indent(3)
        + "} else if let number = jsonValue as? Int {\n".indent(2)
        + "self = Double(number)\n".indent(3)
        + "} else if let number = jsonValue as? Double {\n".indent(2)
        + "self = number\n".indent(3)
        + "} else if let number = jsonValue as? Float {\n".indent(2)
        + "self = Double(number)\n".indent(3)
        + "} else {\n".indent(2)
        + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
        + "}\n".indent(2)
        + "}\n".indent(1)
        + "}\n"
    
    private func createParser(numberType: ModelParser.NumberType, valueExpression: String) -> (parserDeclarations: Set<String>, parsingInstruction: String, typeName: String) {
        let parser: String
        let instruction: String
        let typeName: String
        switch numberType {
        case .Bool:
            parser = ModelParser.FieldType.boolParserDeclaration
            instruction = "try Bool(jsonValue: \(valueExpression))"
            typeName = "Bool"
        case .Int:
            parser = ModelParser.FieldType.intParserDeclaration
            instruction = "try Int(jsonValue: \(valueExpression))"
            typeName = "Int"
        case .Float:
            parser = ModelParser.FieldType.floatParserDeclaration
            instruction = "try Float(jsonValue: \(valueExpression))"
            typeName = "Float"
        case .Double:
            parser = ModelParser.FieldType.doubleParserDeclaration
            instruction = "try Double(jsonValue: \(valueExpression))"
            typeName = "Double"
        }
        return ([ModelParser.FieldType.errorTypeDeclaration, parser], instruction, typeName)
    }
    
    
    
    private func createParsers(parentTypeNames: [String], valueExpression: String) -> (parserDeclarations: Set<String>, parsingInstruction: String, typeName: String) {
        switch self {
        case let .Number(numberType):
            return createParser(numberType, valueExpression: valueExpression)
        case .Text:
            return ([ModelParser.FieldType.stringParserDeclaration], "try String(jsonValue: \(valueExpression))", "String")
        case let .List(listType):
            let (subDeclarations, instruction, typeName) = listType.createParsers(parentTypeNames, valueExpression: "$0")
            return (subDeclarations.union([ModelParser.FieldType.errorTypeDeclaration]), "try ((\(valueExpression)) as? [AnyObject]).map { try $0.map { \(instruction) } } ?? (try { () throws -> [\(typeName)] in throw JsonParsingError.UnsupportedTypeError }())", "[\(typeName)]")
        case let .Optional(optionalType):
            let (subDeclarations, instruction, typeName) = optionalType.createParsers(parentTypeNames, valueExpression: "$0")
            return (subDeclarations, "try (\(valueExpression)).flatMap { if $0 is NSNull { return nil } else { return \(instruction) }}", "\(typeName)?")
        case let .Object(fields):
            var declarations = Set<String>()
            let typeName = parentTypeNames.joinWithSeparator(".")
            var parser = "extension \(typeName) {\n"
                + "init(jsonValue: AnyObject?) throws {\n".indent(1)
                + "if let dict = jsonValue as? [NSObject: AnyObject] {\n".indent(2)
            parser += fields.map { field in
                let (subDeclarations, instruction, _) = field.type.createParsers(parentTypeNames + [field.name.camelCasedString], valueExpression: "dict[\"\(field.name)\"]")
                declarations.unionInPlace(subDeclarations)
                return "self.\(field.name.pascalCasedString.swiftKeywordEscaped) = \(instruction)".indent(3)
                }.joinWithSeparator("\n") + "\n"
            parser += "} else {\n".indent(2)
                + "throw JsonParsingError.UnsupportedTypeError\n".indent(3)
                + "}\n".indent(2)
                + "}\n".indent(1)
                + "}\n"
            declarations.insert(parser)
            return (declarations, "try \(typeName)(jsonValue: \(valueExpression))", typeName)
        case let .Enum(types):
            // TODO
            return ([], "", parentTypeNames.joinWithSeparator("."))
        case .Unknown:
            return ([], "", parentTypeNames.joinWithSeparator("."))
        }
        
    }
    
}