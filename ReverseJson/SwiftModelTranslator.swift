

public class SwiftTranslator: ModelTranslator {
    
    let translators: [ModelTranslator]
    
    public required init(args: [String] = []) {
        translators = [
            SwiftModelCreator(args: args),
            SwiftJsonParsingTranslator(args: args)
        ]
    }
    public func translate(type: ModelParser.FieldType, name: String) -> String {
        return translators.lazy.map { $0.translate(type, name: name) }.joinWithSeparator("\n\n")
    }
}

private enum ObjectType: String {
    case Struct = "struct"
    case Class = "class"
}
extension ObjectType {
    var name: String {
        return self.rawValue
    }
}
private enum ListType: String {
    case Array
    case ContiguousArray
}

private enum Visibility: String {
    case Internal = "internal"
    case Public = "public"
    case Private = "private"
}

extension Visibility {
    var visibilityPrefix: String {
        return self == .Internal ? "" : "\(self.rawValue) "
    }
}

class SwiftModelCreator: ModelTranslator {
    
    private let objectType: ObjectType
    private let listType: ListType
    private let fieldVisibility: Visibility
    private let typeVisibility: Visibility
    private let mutableFields: Bool
    
    required init(args: [String] = []) {
        self.objectType = args.contains("-c") || args.contains("--class") ? .Class : .Struct
        self.listType = args.contains("-ca") || args.contains("--contiguousarray") ? .ContiguousArray : .Array
        self.mutableFields = args.contains("-m") || args.contains("--mutable") ? true : false
        self.fieldVisibility = args.contains("-pf") || args.contains("--publicfields") ? .Public : .Internal
        self.typeVisibility = args.contains("-pt") || args.contains("--publictypes") ? .Public : .Internal
    }
    
    func translate(type: ModelParser.FieldType, name: String) -> String {
        let (typeName, decl) = makeSubtype(type, name: "", subName: name, level: 0)
        if let decl = decl {
            return decl
        }
        return "\(typeVisibility.visibilityPrefix)typealias \(name) = \(typeName)"
    }
    
    private func makeSubtype(type: ModelParser.FieldType, name: String, subName: String, level: Int) -> (name: String, declaration: String?) {
        let fieldType: String
        let declaration: String?
        switch type {
        case let .Object(fields):
            fieldType = subName.camelCasedString
            declaration = createStructDeclaration(fieldType, fields: fields, level: level)
        case let .Number(numberType):
            fieldType = numberType.rawValue
            declaration = nil
        case .Text:
            fieldType = "String"
            declaration = nil
        case let .List(listItemType):
            let newSubName: String
            if case .List = listItemType {
                newSubName = subName
            } else {
                newSubName = "\(subName)Item"
            }
            let (subTypeName, subDeclaration) = makeSubtype(listItemType, name: "\(name)\(subName.camelCasedString)", subName: newSubName, level: level)
            declaration = subDeclaration
            switch listType {
            case .Array: fieldType = "[\(subTypeName)]"
            case .ContiguousArray: fieldType = "\(listType.className)<\(subTypeName)>"
            }
        case let .Enum(enumTypes):
            fieldType = subName.camelCasedString
            declaration = createEnumDeclaration(fieldType, cases: enumTypes, level: level)
        case let .Optional(type):
            let (subTypeName, subDeclaration) = makeSubtype(type, name: name, subName: subName, level: level)
            declaration = subDeclaration
            fieldType = "\(subTypeName)?"
        case .Unknown:
            fieldType = subName.camelCasedString
            declaration = "\(typeVisibility.visibilityPrefix)typealias \(fieldType) = Void // TODO Specify type here. We couldn't infer it from json".indent(level)
        }
        return (fieldType, declaration)
    }
    
    private func createStructDeclaration(name: String, fields: Set<ModelParser.ObjectField>, level: Int = 0) -> String {
        var ret = "\(typeVisibility.visibilityPrefix)\(objectType.name) \(name) {".indent(level)
        let fieldsAndTypes = fields.sort{$0.0.name < $0.1.name}.map { f -> (field: String, type: String?) in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = makeSubtype(f.type, name: name, subName: f.name, level: level + 1)
            let varModifier = mutableFields ? "var" : "let"
            fieldDeclaration += ("\(fieldVisibility.visibilityPrefix)\(varModifier) \(f.name.pascalCasedString.asValidSwiftIdentifier.swiftKeywordEscaped): \(typeName)")
            return (fieldDeclaration, subTypeDeclaration)
        }
        let typeDeclarations = fieldsAndTypes.lazy.flatMap {$0.type}
        ret += Set(typeDeclarations.map({ "\n\($0)"})).sort(<).joinWithSeparator("")
        let fields = fieldsAndTypes.lazy.map { $0.field }.map { $0.indent(level + 1) }.map { "\n\($0)" }
        ret += fields.sort(<).joinWithSeparator("")
        return ret + "\n" + "}".indent(level)
    }
    
    private func createEnumDeclaration(name: String, cases: Set<ModelParser.FieldType>, level: Int = 0) -> String {
        var ret = "\(typeVisibility.visibilityPrefix)enum \(name) {".indent(level)
        ret += cases.sort{$0.0.enumCaseName < $0.1.enumCaseName}.map { c -> String in
            var fieldDeclaration = ""
            let (typeName, subTypeDeclaration) = makeSubtype(c, name: name, subName: "\(name)\(c.enumCaseName)", level: level + 1)
            if let subTypeDeclaration = subTypeDeclaration {
                fieldDeclaration += subTypeDeclaration + "\n"
            }
            fieldDeclaration += "case \(c.enumCaseName)(\(typeName))".indent(level + 1)
            return fieldDeclaration
        }.map {"\n\($0)"} .joinWithSeparator("")
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

let swiftErrorType = [
    "enum JsonParsingError: ErrorType {",
    "    case UnsupportedTypeError",
    "}"
].joinWithSeparator("\n")

let swiftStringParser = [
    "extension String {",
    "    init(jsonValue: AnyObject?) throws {",
    "        guard let string = jsonValue as? String else {",
    "            throw JsonParsingError.UnsupportedTypeError",
    "        }",
    "        self = string",
    "    }",
    "}"
].joinWithSeparator("\n")

let swiftIntParser = [
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
].joinWithSeparator("\n")

let swiftFloatParser = [
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
].joinWithSeparator("\n")

let swiftDoubleParser = [
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
].joinWithSeparator("\n")

let swiftBoolParser = [
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
].joinWithSeparator("\n")

let swiftOptionalParser = [
    "extension Optional {",
    "    init(jsonValue: AnyObject?, map: AnyObject throws -> Wrapped) throws {",
    "        if let jsonValue = jsonValue where !(jsonValue is NSNull) {",
    "            self = try map(jsonValue)",
    "        } else {",
    "            self = nil",
    "        }",
    "    }",
    "}"
].joinWithSeparator("\n")

let swiftArrayParser = [
    "extension Array {",
    "    init(jsonValue: AnyObject?, map: AnyObject throws -> Element) throws {",
    "        guard let items = jsonValue as? [AnyObject] else {",
    "            throw JsonParsingError.UnsupportedTypeError",
    "        }",
    "        self = try items.map(map)",
    "    }",
    "}",
].joinWithSeparator("\n")

let swiftContiguousArrayParser = [
    "extension ContiguousArray {",
    "    init(jsonValue: AnyObject?, map: AnyObject throws -> Element) throws {",
    "        guard let items = jsonValue as? [AnyObject] else {",
    "            throw JsonParsingError.UnsupportedTypeError",
    "        }",
    "        self = ContiguousArray(try items.lazy.map(map))",
    "    }",
    "}"
].joinWithSeparator("\n")

private extension Declaration {
    private static let errorType = Declaration(text: swiftErrorType, priority: 1000)
    private static let arrayParser = Declaration(text: swiftArrayParser, priority: 500)
    private static let contiguousArrayParser = Declaration(text: swiftContiguousArrayParser, priority: 500)
    private static let stringParser = Declaration(text: swiftStringParser, priority: 500)
    private static let boolParser = Declaration(text: swiftBoolParser, priority: 500)
    private static let intParser = Declaration(text: swiftIntParser, priority: 500)
    private static let floatParser = Declaration(text: swiftFloatParser, priority: 500)
    private static let doubleParser = Declaration(text: swiftDoubleParser, priority: 500)
    private static let optionalParser = Declaration(text: swiftOptionalParser, priority:  500)
}

extension ListType {
    var parser: Declaration {
        switch self {
        case .Array: return .arrayParser
        case .ContiguousArray: return .contiguousArrayParser
        }
    }
    var className: String {
        return self.rawValue
    }
}

class SwiftJsonParsingTranslator: ModelTranslator {
    
    private let listType: ListType = .Array
    
    required init(args: [String] = []) {}
    
    func translate(type: ModelParser.FieldType, name: String) -> String {
        let (parsers, instructions, typeName) = createParsers(type, parentTypeNames: [name], valueExpression: "jsonValue")
        
        let declarations = parsers.sort {
            if $0.0.priority > $0.1.priority {
                return true
            } else if $0.0.priority == $0.1.priority {
                return $0.0.text < $0.1.text
            }
            return false
        }.lazy.map { $0.text }.joinWithSeparator("\n\n")
        let parseFunction = [
            "",
            "",
            "func parse\(name.camelCasedString)(jsonValue: AnyObject?) throws -> \(typeName) {",
            "    return \(instructions)",
            "}",
        ].joinWithSeparator("\n")
        return declarations + parseFunction
    }
    
    
    
    private func createParser(numberType: ModelParser.NumberType, valueExpression: String, tryOptional: Bool) -> (parserDeclarations: Set<Declaration>, parsingInstruction: String, typeName: String) {
        let parser: Declaration
        let instruction: String
        let typeName: String
        let tryOptionalModifier = tryOptional ? "?" : ""
        switch numberType {
        case .Bool:
            parser = .boolParser
            instruction = "try\(tryOptionalModifier) Bool(jsonValue: \(valueExpression))"
            typeName = "Bool"
        case .Int:
            parser = .intParser
            instruction = "try\(tryOptionalModifier) Int(jsonValue: \(valueExpression))"
            typeName = "Int"
        case .Float:
            parser = .floatParser
            instruction = "try\(tryOptionalModifier) Float(jsonValue: \(valueExpression))"
            typeName = "Float"
        case .Double:
            parser = .doubleParser
            instruction = "try\(tryOptionalModifier) Double(jsonValue: \(valueExpression))"
            typeName = "Double"
        }
        return ([.errorType, parser], instruction, typeName)
    }
    
    
    
    private func createParsers(type: ModelParser.FieldType, parentTypeNames: [String], valueExpression: String, tryOptional: Bool = false) -> (parserDeclarations: Set<Declaration>, parsingInstruction: String, typeName: String) {
        let tryOptionalModifier = tryOptional ? "?" : ""
        switch type {
        case let .Number(numberType):
            return createParser(numberType, valueExpression: valueExpression, tryOptional: tryOptional)
        case .Text:
            return ([.errorType, .stringParser], "try\(tryOptionalModifier) String(jsonValue: \(valueExpression))", "String")
        case .List(.Unknown):
            return ([], "[]", parentTypeNames.joinWithSeparator("."))
        case let .List(listType):
            let childTypeNames: [String]
            if case .List = listType {
                childTypeNames = parentTypeNames
            } else {
                var names = parentTypeNames
                if let last = names.last {
                    names.removeLast()
                    names.append("\(last)Item")
                }
                childTypeNames = names
            }
            let (subDeclarations, instruction, typeName) = createParsers(listType, parentTypeNames: childTypeNames, valueExpression: "$0")
            let declarations = subDeclarations.union([.errorType, self.listType.parser])
            return (declarations, "try\(tryOptionalModifier) \(self.listType.className)(jsonValue: \(valueExpression)) { \(instruction) }", "[\(typeName)]")
        case .Optional(.Unknown):
            return ([], "nil", parentTypeNames.joinWithSeparator("."))
        case let .Optional(optionalType):
            let (subDeclarations, instruction, typeName) = createParsers(optionalType, parentTypeNames: parentTypeNames, valueExpression: "$0")
            return (subDeclarations.union([.errorType, .optionalParser]), "try\(tryOptionalModifier) Optional(jsonValue: \(valueExpression)) { \(instruction) }", "\(typeName)?")
        case let .Object(fields):
            var declarations = Set<Declaration>()
            let typeName = parentTypeNames.joinWithSeparator(".")
            var parser = [
                "extension \(typeName) {",
                "    init(jsonValue: AnyObject?) throws {",
                "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
                "            throw JsonParsingError.UnsupportedTypeError",
                "        }\n"
            ].joinWithSeparator("\n")
            parser += fields.map { field in
                let (subDeclarations, instruction, _) = createParsers(field.type, parentTypeNames: parentTypeNames + [field.name.camelCasedString], valueExpression: "dict[\"\(field.name)\"]")
                declarations.unionInPlace(subDeclarations)
                return "self.\(field.name.pascalCasedString.asValidSwiftIdentifier.swiftKeywordEscaped) = \(instruction)".indent(2)
                }.joinWithSeparator("\n") + "\n"
            parser += [
                "    }",
                "}"
            ].joinWithSeparator("\n")
            declarations.insert(.errorType)
            declarations.insert(.init(text: parser))
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
                let (subDeclarations, instruction, _) = createParsers(type, parentTypeNames: parentTypeNames + ["\(parentTypeNames.last!)\(type.enumCaseName)"], valueExpression: "jsonValue", tryOptional: true)
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
            declarations.insert(.errorType)
            declarations.insert(.init(text: parser))
            return (declarations, "try\(tryOptionalModifier) \(typeName)(jsonValue: \(valueExpression))", typeName)
        case .Unknown:
            return ([], "nil", parentTypeNames.joinWithSeparator("."))
        }
        
    }

}
