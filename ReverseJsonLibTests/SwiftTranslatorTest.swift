//
//  SwiftTranslatorTest.swift
//  ReverseJson
//
//  Created by Tom Quist on 01.03.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest
@testable import ReverseJsonLib

class SwiftTranslatorTest: XCTestCase {
    
    func testSimpleString() {
        let type: ModelParser.FieldType = .Text

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleText")
        XCTAssertEqual("typealias SimpleText = String", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleText")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "func parseSimpleText(jsonValue: AnyObject?) throws -> String {",
            "    return try String(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testSimpleInt() {
        let type: ModelParser.FieldType = .Number(.Int)

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Int", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftIntParser,
            "",
            "func parseSimpleNumber(jsonValue: AnyObject?) throws -> Int {",
            "    return try Int(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testSimpleFloat() {
        let type: ModelParser.FieldType = .Number(.Float)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Float", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftFloatParser,
            "",
            "func parseSimpleNumber(jsonValue: AnyObject?) throws -> Float {",
            "    return try Float(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testSimpleDouble() {
        let type: ModelParser.FieldType = .Number(.Double)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Double", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftDoubleParser,
            "",
            "func parseSimpleNumber(jsonValue: AnyObject?) throws -> Double {",
            "    return try Double(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testBoolDouble() {
        let type: ModelParser.FieldType = .Number(.Bool)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Bool", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftBoolParser,
            "",
            "func parseSimpleNumber(jsonValue: AnyObject?) throws -> Bool {",
            "    return try Bool(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testEmptyObject() {
        let type: ModelParser.FieldType = .Object([])

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("struct TestObject {\n}", modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testEmptyEnum() {
        let type: ModelParser.FieldType = .Enum([])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("enum TestObject {\n}", modelResult)
    }
    
    func testTextList() {
        let type: ModelParser.FieldType = .List(.Text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("typealias TextList = [String]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> [String] {",
            "    return try Array(jsonValue: jsonValue) { try String(jsonValue: $0) }",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testListOfTextList() {
        let type: ModelParser.FieldType = .List(.List(.Text))
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TextList")
        XCTAssertEqual("typealias TextList = [[String]]", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> [[String]] {",
            "    return try Array(jsonValue: jsonValue) { try Array(jsonValue: $0) { try String(jsonValue: $0) } }",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }

    func testUnknownType() {
        let type: ModelParser.FieldType = .Unknown
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual([
            "func parseMyTypeName(jsonValue: AnyObject?) throws -> MyTypeName {",
            "    return nil",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testOptionalUnknown() {
        let type: ModelParser.FieldType = .Optional(.Unknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual([
            "func parseMyTypeName(jsonValue: AnyObject?) throws -> MyTypeName {",
            "    return nil",
            "}"
            ].joinWithSeparator("\n"), parserResult)
    }
    
    func testListOfUnknown() {
        let type: ModelParser.FieldType = .List(.Unknown)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeNameItem = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual([
            "func parseMyTypeName(jsonValue: AnyObject?) throws -> MyTypeName {",
            "    return []",
            "}"
            ].joinWithSeparator("\n"), parserResult)
    }
    
    func testOptionalText() {
        let type: ModelParser.FieldType = .Optional(.Text)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = String?", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "MyTypeName")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftOptionalParser,
            "",
            swiftStringParser,
            "",
            "func parseMyTypeName(jsonValue: AnyObject?) throws -> String? {",
            "    return try Optional(jsonValue: jsonValue) { try String(jsonValue: $0) }",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testListOfEmptyObject() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.List(.Object([])), name: "TestObjectList")
        XCTAssertEqual("struct TestObjectListItem {\n}", modelResult)
    }
    
    func testObjectWithSingleTextField() {
        let type: ModelParser.FieldType = .Object([.init(name: "text", type: .Text)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "struct TestObject {",
            "    let text: String",
            "}"
        ].joinWithSeparator("\n"), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "        self.text = try String(jsonValue: dict[\"text\"])",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: ModelParser.FieldType = .Object([.init(name: "texts", type: .List(.Text))])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "struct TestObject {",
            "    let texts: [String]",
            "}"
        ].joinWithSeparator("\n"), modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftArrayParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "        self.texts = try Array(jsonValue: dict[\"texts\"]) { try String(jsonValue: $0) }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testObjectWithTwoSimpleFields() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Object([
            .init(name: "number", type: .Number(.Double)),
            .init(name: "texts", type: .List(.Text))
        ]), name: "TestObject")
        XCTAssertEqual([
            "struct TestObject {",
            "    let number: Double",
            "    let texts: [String]",
            "}"
        ].joinWithSeparator("\n"), modelResult)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Object([
            .init(name: "subObject", type: .Object([]))
            ]), name: "TestObject")
        XCTAssertEqual([
            "struct TestObject {",
            "    struct SubObject {",
            "    }",
            "    let subObject: SubObject",
            "}"
        ].joinWithSeparator("\n"), modelResult)
    }

    func testEnumWithOneCase() {
        let type: ModelParser.FieldType = .Enum([.Text])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "enum TestObject {",
            "    case Text(String)",
            "}"
        ].joinWithSeparator("\n"), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        if let value = try? String(jsonValue: jsonValue) {",
            "            self = Text(value)",
            "        } else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }
    
    func testEnumWithTwoCases() {
        let type: ModelParser.FieldType = .Enum([.Text, .Number(.Int)])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "enum TestObject {",
            "    case Number(Int)",
            "    case Text(String)",
            "}"
        ].joinWithSeparator("\n"), modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual([
            swiftErrorType,
            "",
            swiftIntParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        if let value = try? Int(jsonValue: jsonValue) {",
            "            self = Number(value)",
            "        } else if let value = try? String(jsonValue: jsonValue) {",
            "            self = Text(value)",
            "        } else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), parserResult)
    }

    func testEnumWithOneSubDeclarationCase() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Object([])]), name: "TestObject")
        XCTAssertEqual([
            "enum TestObject {",
            "    struct TestObjectObject {",
            "    }",
            "    case Object(TestObjectObject)",
            "}"
        ].joinWithSeparator("\n"), modelResult)
    }
    
    func testPublicTypeFlagWithObject() {
        let type: ModelParser.FieldType = .Object([])
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "TestObject")
        let expected = "public struct TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicTypeFlagWithTypealias() {
        let type: ModelParser.FieldType = .Text
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "SimpleText")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "SimpleText")
        let expected = "public typealias SimpleText = String"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicTypeFlagWithEnum() {
        let type: ModelParser.FieldType = .Enum([])
        
        let modelResult1 = SwiftModelCreator(args: ["-pt"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publictypes"]).translate(type, name: "TestObject")
        let expected = "public enum TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }

    func testClassFlag() {
        let type: ModelParser.FieldType = .Object([])
        
        let modelResult1 = SwiftModelCreator(args: ["-c"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--class"]).translate(type, name: "TestObject")
        let expected = "class TestObject {\n}"
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testPublicFieldsFlag() {
        let type: ModelParser.FieldType = .Object([.init(name: "text", type: .Text)])
        
        let modelResult1 = SwiftModelCreator(args: ["-pf"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--publicfields"]).translate(type, name: "TestObject")
        let expected = [
            "struct TestObject {",
            "    public let text: String",
            "}"
        ].joinWithSeparator("\n")
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testMutableFieldsFlag() {
        let type: ModelParser.FieldType = .Object([.init(name: "text", type: .Text)])
        
        let modelResult1 = SwiftModelCreator(args: ["-m"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--mutable"]).translate(type, name: "TestObject")
        let expected = [
            "struct TestObject {",
            "    var text: String",
            "}"
        ].joinWithSeparator("\n")
        XCTAssertEqual(expected, modelResult1)
        XCTAssertEqual(expected, modelResult2)
    }
    
    func testContiguousArrayFlag() {
        let type: ModelParser.FieldType = .Object([.init(name: "texts", type: .List(.Text))])
        
        let modelResult1 = SwiftModelCreator(args: ["-ca"]).translate(type, name: "TestObject")
        let modelResult2 = SwiftModelCreator(args: ["--contiguousarray"]).translate(type, name: "TestObject")
        let expectedModel = [
            "struct TestObject {",
            "    let texts: ContiguousArray<String>",
            "}"
        ].joinWithSeparator("\n")
        XCTAssertEqual(expectedModel, modelResult1)
        XCTAssertEqual(expectedModel, modelResult2)
        
        let parserResult1 = SwiftJsonParsingTranslator(args: ["-ca"]).translate(type, name: "TestObject")
        let parserResult2 = SwiftJsonParsingTranslator(args: ["--contiguousarray"]).translate(type, name: "TestObject")
        let expectedParser = [
            swiftErrorType,
            "",
            swiftContiguousArrayParser,
            "",
            swiftStringParser,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "        self.texts = try ContiguousArray(jsonValue: dict[\"texts\"]) { try String(jsonValue: $0) }",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n")
        XCTAssertEqual(expectedParser, parserResult1)
        XCTAssertEqual(expectedParser, parserResult2)
    }
    
    func testTranslatorCombination() {
        let type: ModelParser.FieldType = .Object([])
        
        let translator = SwiftTranslator()
        let result = translator.translate(type, name: "TestObject")
        XCTAssertEqual([
            "struct TestObject {",
            "}",
            "",
            swiftErrorType,
            "",
            "extension TestObject {",
            "    init(jsonValue: AnyObject?) throws {",
            "        guard let dict = jsonValue as? [NSObject: AnyObject] else {",
            "            throw JsonParsingError.UnsupportedTypeError",
            "        }",
            "",
            "    }",
            "}",
            "",
            "func parseTestObject(jsonValue: AnyObject?) throws -> TestObject {",
            "    return try TestObject(jsonValue: jsonValue)",
            "}"
        ].joinWithSeparator("\n"), result)
    }
    
}
