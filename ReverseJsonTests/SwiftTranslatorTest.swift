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
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftStringParser)\n\nfunc parseSimpleText(jsonValue: AnyObject?) throws -> String {\n    return try String(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testSimpleInt() {
        let type: ModelParser.FieldType = .Number(.Int)

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Int", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftIntParser)\n\nfunc parseSimpleNumber(jsonValue: AnyObject?) throws -> Int {\n    return try Int(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testSimpleFloat() {
        let type: ModelParser.FieldType = .Number(.Float)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Float", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftFloatParser)\n\nfunc parseSimpleNumber(jsonValue: AnyObject?) throws -> Float {\n    return try Float(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testSimpleDouble() {
        let type: ModelParser.FieldType = .Number(.Double)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Double", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftDoubleParser)\n\nfunc parseSimpleNumber(jsonValue: AnyObject?) throws -> Double {\n    return try Double(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testBoolDouble() {
        let type: ModelParser.FieldType = .Number(.Bool)
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("typealias SimpleNumber = Bool", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "SimpleNumber")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftBoolParser)\n\nfunc parseSimpleNumber(jsonValue: AnyObject?) throws -> Bool {\n    return try Bool(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testEmptyObject() {
        let type: ModelParser.FieldType = .Object([])

        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("struct TestObject {\n}", modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual("\(swiftErrorType)\n\nextension TestObject {\n    init(jsonValue: AnyObject?) throws {\n        if let dict = jsonValue as? [NSObject: AnyObject] {\n\n        } else {\n            throw JsonParsingError.UnsupportedTypeError\n        }\n    }\n}\n\nfunc parseTestObject(jsonValue: AnyObject?) throws -> TestObject {\n    return try TestObject(jsonValue: jsonValue)\n}", parserResult)
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
        XCTAssertEqual("struct TestObject {\n    let text: String\n}", modelResult)
        
        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftStringParser)\n\nextension TestObject {\n    init(jsonValue: AnyObject?) throws {\n        if let dict = jsonValue as? [NSObject: AnyObject] {\n            self.text = try String(jsonValue: dict[\"text\"])\n        } else {\n            throw JsonParsingError.UnsupportedTypeError\n        }\n    }\n}\n\nfunc parseTestObject(jsonValue: AnyObject?) throws -> TestObject {\n    return try TestObject(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: ModelParser.FieldType = .Object([.init(name: "texts", type: .List(.Text))])
        
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(type, name: "TestObject")
        XCTAssertEqual("struct TestObject {\n    let texts: [String]\n}", modelResult)

        let parserCreator = SwiftJsonParsingTranslator()
        let parserResult = parserCreator.translate(type, name: "TestObject")
        XCTAssertEqual("\(swiftErrorType)\n\n\(swiftArrayParser)\n\n\(swiftStringParser)\n\nextension TestObject {\n    init(jsonValue: AnyObject?) throws {\n        if let dict = jsonValue as? [NSObject: AnyObject] {\n            self.texts = try Array(jsonValue: dict[\"texts\"]) { try String(jsonValue: $0) }\n        } else {\n            throw JsonParsingError.UnsupportedTypeError\n        }\n    }\n}\n\nfunc parseTestObject(jsonValue: AnyObject?) throws -> TestObject {\n    return try TestObject(jsonValue: jsonValue)\n}", parserResult)
    }
    
    func testObjectWithTwoSimpleFields() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Object([
            .init(name: "number", type: .Number(.Double)),
            .init(name: "texts", type: .List(.Text))
        ]), name: "TestObject")
        XCTAssertEqual("struct TestObject {\n    let number: Double\n    let texts: [String]\n}", modelResult)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Object([
            .init(name: "subObject", type: .Object([]))
            ]), name: "TestObject")
        XCTAssertEqual("struct TestObject {\n    struct SubObject {\n    }\n    let subObject: SubObject\n}", modelResult)
    }

    func testEnumWithOneCase() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Text]), name: "TestObject")
        XCTAssertEqual("enum TestObject {\n    case Text(String)\n}", modelResult)
    }
    
    func testEnumWithTwoCases() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Text, .Number(.Int)]), name: "TestObject")
        XCTAssertEqual("enum TestObject {\n    case Number(Int)\n    case Text(String)\n}", modelResult)
    }

    func testEnumWithOneSubDeclarationCase() {
        let modelCreator = SwiftModelCreator()
        let modelResult = modelCreator.translate(.Enum([.Object([])]), name: "TestObject")
        XCTAssertEqual("enum TestObject {\n    struct TestObjectObject {\n    }\n    case Object(TestObjectObject)\n}", modelResult)
    }
    
}
