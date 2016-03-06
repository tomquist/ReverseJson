//
//  SwiftTranslatorTest.swift
//  ReverseJson
//
//  Created by Tom Quist on 01.03.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest

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
            "}"].joinWithSeparator("\n"), parserResult)
    }
    
    func testEmptyEnum() {
        let type: ModelParser.FieldType = .Enum([])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("enum TestObject {\n}", modelResult)
    }
    
    func testTextList() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.List(.Text), name: "TextList")
        XCTAssertEqual("typealias TextList = [String]", modelResult)
    }
    
    func testListOfTextList() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.List(.List(.Text)), name: "TextList")
        XCTAssertEqual("typealias TextList = [[String]]", modelResult)
    }

    func testUnknownType() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Unknown, name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = Void // TODO Specify type here. We couldn't infer it from json", modelResult)
    }
    
    func testOptionalText() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Optional(.Text), name: "MyTypeName")
        XCTAssertEqual("typealias MyTypeName = String?", modelResult)        
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
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Text]), name: "TestObject")
        XCTAssertEqual([
            "enum TestObject {",
            "    case Text(String)",
            "}"
        ].joinWithSeparator("\n"), modelResult)
    }
    
    func testEnumWithTwoCases() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Text, .Number(.Int)]), name: "TestObject")
        XCTAssertEqual([
            "enum TestObject {",
            "    case Number(Int)",
            "    case Text(String)",
            "}"
        ].joinWithSeparator("\n"), modelResult)
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
    
}
