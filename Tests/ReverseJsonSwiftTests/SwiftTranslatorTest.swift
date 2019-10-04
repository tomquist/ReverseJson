
import XCTest
import ReverseJsonCore
@testable import ReverseJsonSwift

class SwiftTranslatorTest: XCTestCase {
    
    func testSimpleString() {
        let type: FieldType = .text

        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias SimpleText = String", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "SimpleText")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "func parseSimpleText(jsonValue: Any?) throws -> String {",
            "    return try String(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testSimpleInt() {
        let type: FieldType = .number(.int)

        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias SimpleNumber = Int", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftIntParser,
            "",
            "func parseSimpleNumber(jsonValue: Any?) throws -> Int {",
            "    return try Int(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testSimpleFloat() {
        let type: FieldType = .number(.float)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias SimpleNumber = Float", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftFloatParser,
            "",
            "func parseSimpleNumber(jsonValue: Any?) throws -> Float {",
            "    return try Float(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testSimpleDouble() {
        let type: FieldType = .number(.double)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias SimpleNumber = Double", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftDoubleParser,
            "",
            "func parseSimpleNumber(jsonValue: Any?) throws -> Double {",
            "    return try Double(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testBoolDouble() {
        let type: FieldType = .number(.bool)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias SimpleNumber = Bool", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftBoolParser,
            "",
            "func parseSimpleNumber(jsonValue: Any?) throws -> Bool {",
            "    return try Bool(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testEmptyObject() {
        let type: FieldType = .unnamedObject([])

        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("// \(modelCreator.fileName)\nstruct TestObject {\n}", modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        guard let dict = jsonValue as? [String: Any] else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testEmptyEnum() {
        let type: FieldType = .unnamedEnum([])
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("// \(modelCreator.fileName)\nenum TestObject {\n}", modelResult)
    }
    
    func testTextList() {
        let type: FieldType = .list(.text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias TextList = [String]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "func parseTestObject(jsonValue: Any?) throws -> [String] {",
            "    return try Array(jsonValue: jsonValue) { try String(jsonValue: $0) }",
            "}"
        ), parserResult)
    }
    
    func testListOfTextList() {
        let type: FieldType = .list(.list(.text))
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias TextList = [[String]]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "func parseTestObject(jsonValue: Any?) throws -> [[String]] {",
            "    return try Array(jsonValue: jsonValue) { try Array(jsonValue: $0) { try String(jsonValue: $0) } }",
            "}"
        ), parserResult)
    }

    func testUnknownType() {
        let type: FieldType = .unnamedUnknown
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return nil",
            "}"
        ), parserResult)
    }
    
    func testOptionalUnknown() {
        let type: FieldType = .optional(.unnamedUnknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return nil",
            "}"
        ), parserResult)
    }
    
    func testListOfUnknown() {
        let type: FieldType = .list(.unnamedUnknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias MyTypeNameItem = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return []",
            "}"
        ), parserResult)
    }
    
    func testOptionalText() {
        let type: FieldType = .optional(.text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("// \(modelCreator.fileName)\ntypealias MyTypeName = String?", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftOptionalParser,
            "",
            swiftStringParser,
            "",
            "func parseMyTypeName(jsonValue: Any?) throws -> String? {",
            "    return try Optional(jsonValue: jsonValue) { try String(jsonValue: $0) }",
            "}"
        ), parserResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(.list(.unnamedObject([])), name: "TestObjectList")
        XCTAssertEqual("// \(modelCreator.fileName)\nstruct TestObjectListItem {\n}", modelResult)
    }
    
    func testObjectWithSingleTextField() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    let text: String",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        guard let dict = jsonValue as? [String: Any] else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "        self.text = try String(jsonValue: dict[\"text\"])",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    let texts: [String]",
            "}"
        ), modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        guard let dict = jsonValue as? [String: Any] else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "        self.texts = try Array(jsonValue: dict[\"texts\"]) { try String(jsonValue: $0) }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testObjectWithTwoSimpleFields() {
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(.unnamedObject([
            .init(name: "number", type: .number(.double)),
            .init(name: "texts", type: .list(.text))
        ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    let number: Double",
            "    let texts: [String]",
            "}"
        ), modelResult)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(.unnamedObject([
            .init(name: "subObject", type: .unnamedObject([]))
            ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    struct SubObject {",
            "    }",
            "    let subObject: SubObject",
            "}"
        ), modelResult)
    }

    func testEnumWithOneCase() {
        let type: FieldType = .unnamedEnum([.text])
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "enum TestObject {",
            "    case text(String)",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        if let value = try? String(jsonValue: jsonValue) {",
            "            self = .text(value)",
            "        } else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }
    
    func testEnumWithTwoCases() {
        let type: FieldType = .unnamedEnum([.text, .number(.int)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "enum TestObject {",
            "    case number(Int)",
            "    case text(String)",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult: String = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(parserCreator.fileName)",
            swiftErrorType,
            "",
            swiftIntParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        if let value = try? Int(jsonValue: jsonValue) {",
            "            self = .number(value)",
            "        } else if let value = try? String(jsonValue: jsonValue) {",
            "            self = .text(value)",
            "        } else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), parserResult)
    }

    func testEnumWithOneSubDeclarationCase() {
        let modelCreator = SwiftModelCreator()
        let modelResult: String = modelCreator.translate(.unnamedEnum([.unnamedObject([])]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(modelCreator.fileName)",
            "enum TestObject {",
            "    struct TestObjectObject {",
            "    }",
            "    case object(TestObjectObject)",
            "}"
        ), modelResult)
    }
    
    func testPublicTypeFlagWithObject() {
        let type: FieldType = .unnamedObject([])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.typeVisibility = .publicVisibility
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = "// \(modelCreator.fileName)\npublic struct TestObject {\n}"
        XCTAssertEqual(expected, modelResult)
    }
    
    func testPublicTypeFlagWithTypealias() {
        let type: FieldType = .text
        
        var modelCreator = SwiftModelCreator()
        modelCreator.typeVisibility = .publicVisibility
        let modelResult: String = modelCreator.translate(type, name: "SimpleText")
        let expected = "// \(modelCreator.fileName)\npublic typealias SimpleText = String"
        XCTAssertEqual(expected, modelResult)
    }
    
    func testPublicTypeFlagWithEnum() {
        let type: FieldType = .unnamedEnum([])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.typeVisibility = .publicVisibility
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = "// \(modelCreator.fileName)\npublic enum TestObject {\n}"
        XCTAssertEqual(expected, modelResult)
    }

    func testClassFlag() {
        let type: FieldType = .unnamedObject([])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.objectType = .classType
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = "// \(modelCreator.fileName)\nclass TestObject {\n}"
        XCTAssertEqual(expected, modelResult)
    }
    
    func testPublicFieldsFlag() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.fieldVisibility = .publicVisibility
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    public let text: String",
            "}"
        )
        XCTAssertEqual(expected, modelResult)
    }
    
    func testMutableFieldsFlag() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.mutableFields = true
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expected = String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    var text: String",
            "}"
        )
        XCTAssertEqual(expected, modelResult)
    }
    
    func testContiguousArrayFlag() {
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        
        var modelCreator = SwiftModelCreator()
        modelCreator.listType = .contiguousArray
        let modelResult: String = modelCreator.translate(type, name: "TestObject")
        let expectedModel = String(lines:
            "// \(modelCreator.fileName)",
            "struct TestObject {",
            "    let texts: ContiguousArray<String>",
            "}"
        )
        XCTAssertEqual(expectedModel, modelResult)
        
        var mappingCreator = SwiftJsonParsingTranslator()
        mappingCreator.listType = .contiguousArray
        let parserResult: String = mappingCreator.translate(type, name: "TestObject")
        let expectedParser = String(lines:
            "// \(mappingCreator.fileName)",
            swiftErrorType,
            "",
            swiftContiguousArrayParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        guard let dict = jsonValue as? [String: Any] else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "        self.texts = try ContiguousArray(jsonValue: dict[\"texts\"]) { try String(jsonValue: $0) }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        )
        XCTAssertEqual(expectedParser, parserResult)
    }
    
    func testTranslatorCombination() {
        let type: FieldType = .unnamedObject([])
        
        let translator = SwiftTranslator()
        let result: String = translator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "// \(translator.modelFileName)",
            "struct TestObject {",
            "}",
            "// \(translator.mappingFileName)",
            swiftErrorType,
            "",
            "extension TestObject {",
            "    init(jsonValue: Any?) throws {",
            "        guard let dict = jsonValue as? [String: Any] else {",
            "            throw JsonParsingError.unsupportedTypeError",
            "        }",
            "",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: Any?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ), result)
    }
}
