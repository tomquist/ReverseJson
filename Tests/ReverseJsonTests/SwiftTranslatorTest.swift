
import XCTest
@testable import ReverseJson

class SwiftTranslatorTest: XCTestCase {
    
    static var allTests: [(String, (SwiftTranslatorTest) -> () throws -> Void)] {
        return [
            ("testBoolDouble", testBoolDouble),
            ("testClassFlag", testClassFlag),
            ("testContiguousArrayFlag", testContiguousArrayFlag),
            ("testEmptyEnum", testEmptyEnum),
            ("testEmptyObject", testEmptyObject),
            ("testEnumWithOneCase", testEnumWithOneCase),
            ("testEnumWithOneSubDeclarationCase", testEnumWithOneSubDeclarationCase),
            ("testEnumWithTwoCases", testEnumWithTwoCases),
            ("testListOfEmptyObject", testListOfEmptyObject),
            ("testListOfTextList", testListOfTextList),
            ("testListOfUnknown", testListOfUnknown),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testObjectWithFieldContainingListOfText", testObjectWithFieldContainingListOfText),
            ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
            ("testObjectWithSingleTextField", testObjectWithSingleTextField),
            ("testObjectWithTwoSimpleFields", testObjectWithTwoSimpleFields),
            ("testOptionalText", testOptionalText),
            ("testOptionalUnknown", testOptionalUnknown),
            ("testPublicFieldsFlag", testPublicFieldsFlag),
            ("testPublicTypeFlagWithEnum", testPublicTypeFlagWithEnum),
            ("testPublicTypeFlagWithObject", testPublicTypeFlagWithObject),
            ("testPublicTypeFlagWithTypealias", testPublicTypeFlagWithTypealias),
            ("testSimpleDouble", testSimpleDouble),
            ("testSimpleFloat", testSimpleFloat),
            ("testSimpleInt", testSimpleInt),
            ("testSimpleString", testSimpleString),
            ("testTextList", testTextList),
            ("testTranslatorCombination", testTranslatorCombination),
            ("testUnknownType", testUnknownType),
        ]
    }
    
    func testSimpleString() {
        let type: FieldType = .text

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("typealias SimpleText = String", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleText")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Int", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Float", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Double", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Bool", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual(String(lines:
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
        let type: FieldType = .object([])

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("struct TestObject {\n}", modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let type: FieldType = .enum([])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("enum TestObject {\n}", modelResult)
    }
    
    func testTextList() {
        let type: FieldType = .list(.text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("typealias TextList = [String]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("typealias TextList = [[String]]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let type: FieldType = .unknown
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return nil",
            "}"
        ), parserResult)
    }
    
    func testOptionalUnknown() {
        let type: FieldType = .optional(.unknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return nil",
            "}"
        ), parserResult)
    }
    
    func testListOfUnknown() {
        let type: FieldType = .list(.unknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeNameItem = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
            "func parseMyTypeName(jsonValue: Any?) throws -> MyTypeName {",
            "    return []",
            "}"
        ), parserResult)
    }
    
    func testOptionalText() {
        let type: FieldType = .optional(.text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = String?", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(.list(.object([])), name: "TestObjectList")
        XCTAssertEqual("struct TestObjectListItem {\n}", modelResult)
    }
    
    func testObjectWithSingleTextField() {
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "struct TestObject {",
            "    let text: String",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let type: FieldType = .object([.init(name: "texts", type: .list(.text))])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "struct TestObject {",
            "    let texts: [String]",
            "}"
        ), modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(.object([
            .init(name: "number", type: .number(.double)),
            .init(name: "texts", type: .list(.text))
        ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "struct TestObject {",
            "    let number: Double",
            "    let texts: [String]",
            "}"
        ), modelResult)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.object([
            .init(name: "subObject", type: .object([]))
            ]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "struct TestObject {",
            "    struct SubObject {",
            "    }",
            "    let subObject: SubObject",
            "}"
        ), modelResult)
    }

    func testEnumWithOneCase() {
        let type: FieldType = .enum([.text])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "enum TestObject {",
            "    case text(String)",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let type: FieldType = .enum([.text, .number(.int)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "enum TestObject {",
            "    case number(Int)",
            "    case text(String)",
            "}"
        ), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
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
        let modelResult = modelCreator.translate(.enum([.object([])]), name: "TestObject")
        XCTAssertEqual(String(lines:
            "enum TestObject {",
            "    struct TestObjectObject {",
            "    }",
            "    case object(TestObjectObject)",
            "}"
        ), modelResult)
    }
    
    func testPublicTypeFlagWithObject() {
        let type: FieldType = .object([])
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "TestObject")
        let expected = "public struct TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicTypeFlagWithTypealias() {
        let type: FieldType = .text
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "SimpleText")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "SimpleText")
        let expected = "public typealias SimpleText = String"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicTypeFlagWithEnum() {
        let type: FieldType = .enum([])
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "TestObject")
        let expected = "public enum TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }

    func testClassFlag() {
        let type: FieldType = .object([])
        
        let modelResult1 = SwiftModelCreator(args: ["-c"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--class"]).translate(type, name: "TestObject")
        let expected = "class TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicFieldsFlag() {
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        let modelResult1 = SwiftModelCreator(args: ["-pf"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publicfields"]).translate(type, name: "TestObject")
        let expected = String(lines:
            "struct TestObject {",
            "    public let text: String",
            "}"
        )
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testMutableFieldsFlag() {
        let type: FieldType = .object([.init(name: "text", type: .text)])
        
        let modelResult1 = SwiftModelCreator(args: ["-m"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--mutable"]).translate(type, name: "TestObject")
        let expected = String(lines:
            "struct TestObject {",
            "    var text: String",
            "}"
        )
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testContiguousArrayFlag() {
        let type: FieldType = .object([.init(name: "texts", type: .list(.text))])
        
        let modelResult1 = SwiftModelCreator(args: ["-ca"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--contiguousarray"]).translate(type, name: "TestObject")
        let expectedModel = String(lines:
            "struct TestObject {",
            "    let texts: ContiguousArray<String>",
            "}"
        )
        XCTAssertEqual(expectedModel, modelResult1)
        XCTAssertEqual(expectedModel, modelResult2)
        
        let parserResult1 = SwiftJsonParsingTranslator(args: ["-ca"]).translate(type, name: "TestObject")
        let parserResult2 = SwiftJsonParsingTranslator(args: ["--contiguousarray"]).translate(type, name: "TestObject")
        let expectedParser = String(lines:
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
        XCTAssertEqual(expectedParser, parserResult1)
        XCTAssertEqual(expectedParser, parserResult2)
    }
    
    func testTranslatorCombination() {
        let type: FieldType = .object([])
        
        let translator = SwiftTranslator()
        let result = translator.translate(type, name: "TestObject")
        XCTAssertEqual(String(lines:
            "struct TestObject {",
            "}",
            "",
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
