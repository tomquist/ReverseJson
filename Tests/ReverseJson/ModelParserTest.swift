//
//  ReverseJsonTests.swift
//  ReverseJsonTests
//
//  Created by Tom Quist on 28.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest
import Foundation
@testable import ReverseJson

class ModelParserTest: XCTestCase, XCTestCaseProvider {
    
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testArrayObjectWithArrayFieldOfIntsStringsAndDoubles", testArrayObjectWithArrayFieldOfIntsStringsAndDoubles),
            ("testArrayObjectWithArrayFieldOfUnknownTypeAndStrings", testArrayObjectWithArrayFieldOfUnknownTypeAndStrings),
            ("testArrayObjectWithMixedFieldOfMixedArraysAndInt", testArrayObjectWithMixedFieldOfMixedArraysAndInt),
            ("testArrayOfEmptyObject", testArrayOfEmptyObject),
            ("testArrayOfEmptyOptionalObject", testArrayOfEmptyOptionalObject),
            ("testArrayOfMixedBoolAndDouble", testArrayOfMixedBoolAndDouble),
            ("testArrayOfMixedBoolIntAndDouble", testArrayOfMixedBoolIntAndDouble),
            ("testArrayOfMixedIntAndFloat", testArrayOfMixedIntAndFloat),
            ("testArrayOfMixedIntFloatAndDouble", testArrayOfMixedIntFloatAndDouble),
            ("testArrayOfObjectsWithMissingField", testArrayOfObjectsWithMissingField),
            ("testArrayOfObjectsWithMixedTypesAndOptional", testArrayOfObjectsWithMixedTypesAndOptional),
            ("testBool", testBool),
            ("testDouble", testDouble),
            ("testEmptyArray", testEmptyArray),
            ("testEmptyObject", testEmptyObject),
            ("testEqualNumberTypes", testEqualNumberTypes),
            ("testEqualTypeEnum", testEqualTypeEnum),
            ("testEqualTypeList", testEqualTypeList),
            ("testEqualTypeNumber", testEqualTypeNumber),
            ("testEqualTypeObject", testEqualTypeObject),
            ("testEqualTypeOptional", testEqualTypeOptional),
            ("testEqualTypeText", testEqualTypeText),
            ("testEqualTypeUnknown", testEqualTypeUnknown),
            ("testFloat", testFloat),
            ("testInt", testInt),
            ("testIntArray", testIntArray),
            ("testNullArray", testNullArray),
            ("testOptionalStringArray", testOptionalStringArray),
            ("testSingleFieldObject", testSingleFieldObject),
            ("testString", testString),
            ("testStringArray", testStringArray),
            ("testThreeFieldsObject", testThreeFieldsObject),
            ("testUnsupported", testUnsupported),
            ("testTransformAllFieldsToOptional", testTransformAllFieldsToOptional),
            ("testTransformAllFieldsToOptionalWithToplevelList", testTransformAllFieldsToOptionalWithToplevelList),
            ("testTransformAllFieldsToOptionalWithToplevelEnum", testTransformAllFieldsToOptionalWithToplevelEnum)
        ]
    }
    
    var parser: ModelParser = ModelParser()
    
    func XCTAsserEqualFieldType(fieldType1: ModelParser.FieldType, _ fieldType2: ModelParser.FieldType) {
        XCTAssertEqual(fieldType1, fieldType2)
    }
    func XCTAsserNotEqualFieldType(fieldType1: ModelParser.FieldType, _ fieldType2: ModelParser.FieldType) {
        XCTAssertNotEqual(fieldType1, fieldType2)
    }
    
    func testEqualTypeUnknown() {
        XCTAsserEqualFieldType(.Unknown, .Unknown)
        XCTAsserNotEqualFieldType(.Unknown, .Number(.Int))
    }
    
    func testEqualTypeText() {
        XCTAsserEqualFieldType(ModelParser.FieldType.Text, .Text)
        XCTAsserNotEqualFieldType(.Text, .Number(.Int))
    }
    
    func testEqualNumberTypes() {
        XCTAssertEqual(ModelParser.NumberType.Int, ModelParser.NumberType.Int)
        XCTAssertEqual(ModelParser.NumberType.Float, ModelParser.NumberType.Float)
        XCTAssertEqual(ModelParser.NumberType.Bool, ModelParser.NumberType.Bool)
        XCTAssertEqual(ModelParser.NumberType.Double, ModelParser.NumberType.Double)
        XCTAssertNotEqual(ModelParser.NumberType.Int, ModelParser.NumberType.Double)
        XCTAssertNotEqual(ModelParser.NumberType.Float, ModelParser.NumberType.Double)
    }

    func testEqualTypeNumber() {
        XCTAsserEqualFieldType(.Number(.Int), .Number(.Int))
        XCTAsserNotEqualFieldType(.Number(.Int), .Text)
        XCTAsserNotEqualFieldType(.Number(.Int), .Number(.Double))
    }
    
    func testEqualTypeList() {
        XCTAsserEqualFieldType(.List(.Text), .List(.Text))
        XCTAsserNotEqualFieldType(.List(.Text), .Text)
        XCTAsserNotEqualFieldType(.List(.Text), .List(.Number(.Int)))
    }
    
    func testEqualTypeOptional() {
        XCTAsserEqualFieldType(.Optional(.Text), .Optional(.Text))
        XCTAsserNotEqualFieldType(.Optional(.Text), .Text)
        XCTAsserNotEqualFieldType(.Optional(.Text), .List(.Text))
        XCTAsserNotEqualFieldType(.Optional(.Text), .Optional(.Number(.Int)))
    }
    
    func testEqualTypeObject() {
        XCTAsserEqualFieldType(.Object([]), .Object([]))
        XCTAsserEqualFieldType(.Object([.init(name: "object", type: .Text)]), .Object([.init(name: "object", type: .Text)]))
        XCTAsserEqualFieldType(.Object([
            .init(name: "object", type: .Text),
            .init(name: "int", type: .Number(.Int)),
        ]), .Object([
            .init(name: "int", type: .Number(.Int)),
            .init(name: "object", type: .Text),
        ]))
        XCTAsserNotEqualFieldType(.Object([
            .init(name: "object", type: .Text),
            .init(name: "int", type: .Number(.Int)),
        ]), .Object([
            .init(name: "int", type: .Text),
            .init(name: "object", type: .Text),
        ]))
        XCTAsserNotEqualFieldType(.Object([
            .init(name: "object", type: .Text),
            .init(name: "integer", type: .Number(.Int)),
        ]), .Object([
            .init(name: "int", type: .Number(.Int)),
            .init(name: "object", type: .Text),
        ]))
        XCTAsserNotEqualFieldType(.Object([
            .init(name: "object", type: .Text),
        ]), .Object([
            .init(name: "int", type: .Number(.Int)),
            .init(name: "object", type: .Text),
        ]))
        XCTAsserNotEqualFieldType(.Object([.init(name: "object", type: .Text)]), .Object([.init(name: "text", type: .Text)]))
        XCTAsserNotEqualFieldType(.Object([.init(name: "object", type: .Text)]), .Text)
    }
    
    func testEqualTypeEnum() {
        XCTAsserEqualFieldType(.Enum([]), .Enum([]))
        XCTAsserEqualFieldType(.Enum([.Text]), .Enum([.Text]))
        XCTAsserEqualFieldType(.Enum([
            .Text,
            .Number(.Int),
        ]), .Enum([
            .Number(.Int),
            .Text,
        ]))
        XCTAsserNotEqualFieldType(.Enum([
            .Text,
            .Number(.Int),
        ]), .Enum([
            .Text
        ]))
        XCTAsserNotEqualFieldType(.Enum([.Text]), .Enum([.Number(.Int)]))
        XCTAsserNotEqualFieldType(.Enum([.Text]), .Text)
    }
    
    func testString() throws {
        let type = try parser.decode("Simple string")
        XCTAssertEqual(type, ModelParser.FieldType.Text)
    }
    
    func testInt() throws {
        let type = try parser.decode(10)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Int))
    }
    
    func testDouble() throws {
        let type = try parser.decode(10.0)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Double))
    }
    
    func testFloat() throws {
        let type = try parser.decode(Float(10.0))
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Float))
    }
    
    func testBool() throws {
        let type = try parser.decode(true)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Bool))
    }
    
    func testJsonBool() throws {
        let data = "{\"value\":true}".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj["value"])
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Bool))
    }
    
    func testJsonInt() throws {
        let data = "{\"value\":1}".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj["value"])
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Int))
    }
    
    func testJsonDouble() throws {
        let data = "{\"value\":1.2}".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj["value"])
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Double))
    }

    func testJsonString() throws {
        let data = "{\"value\":\"simple string\"}".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj["value"])
        XCTAssertEqual(type, ModelParser.FieldType.Text)
    }
    
    func testJsonEmptyObject() throws {
        let data = "{}".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.Object([]))
    }
    
    func testJsonEmptyArray() throws {
        let data = "[]".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.List(.Unknown))
    }
    
    func testJsonNullArray() throws {
        let data = "[null, null]".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Unknown)))
    }
    
    func testJsonStringArray() throws {
        let data = "[\"Test\", \"123\"]".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.List(.Text))
    }
    
    func testJsonIntArray() throws {
        let data = "[1,2,3]".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.List(.Number(.Int)))
    }
    
    func testJsonOptionalStringArray() throws {
        let data = "[\"Test\", \"123\", null]".dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let type = try parser.decode(jsonObj)
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Text)))
    }
    
    func testEmptyObject() throws {
        let type = try parser.decode(Dictionary<String, Any>())
        XCTAssertEqual(type, ModelParser.FieldType.Object([]))
    }
    
    func testEmptyArray() throws {
        let type = try parser.decode(Array<Any>())
        XCTAssertEqual(type, ModelParser.FieldType.List(.Unknown))
    }

    func testStringArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            "Test",
            "123"
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Text))
    }
    
    func testIntArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Int(20)
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Number(.Int)))
    }

    func testOptionalStringArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            "Test",
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Text)))
    }
    
    func testNullArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Unknown)))
    }

    func testSingleFieldObject() throws {
        let type = try parser.decode(Dictionary<String, Any>(dictionaryLiteral:
            ("string", "Test")
        ))
        XCTAssertEqual(type, ModelParser.FieldType.Object([ModelParser.ObjectField(name: "string", type: .Text)]))
    }
    
    func testThreeFieldsObject() throws {
        let type = try parser.decode(Dictionary<String, Any>(dictionaryLiteral:
            ("string", "Test"),
            ("integer", 123),
            ("object", Dictionary<String, Any>())
        ))
        let expectedType: ModelParser.FieldType = .Object([
            .init(name: "string", type: .Text),
            .init(name: "integer", type: .Number(.Int)),
            .init(name: "object", type: .Object([]))
        ])
        XCTAssertEqual(type, expectedType)
    }

    func testArrayOfEmptyObject() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            Dictionary<String, Any>()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Object([])))
    }
    
    func testArrayOfEmptyOptionalObject() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Object([]))))
    }
    
    func testArrayOfMixedIntFloatAndDouble() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Double(10),
            Float(10)
        ))
        XCTAssertEqual(type, ModelParser.FieldType.List(.Number(.Double)), "Mixed number types with at least one Double should be merged to Double")
    }
    
    func testArrayOfMixedIntAndFloat() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Float(10)
        ))
        let expectedResult: ModelParser.FieldType = .List(
            .Number(.Float)
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Int and Float should be merged to Float")
    }

    func testArrayOfMixedBoolAndDouble() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Double(10),
            true
        ))
        let expectedResult: ModelParser.FieldType = .List(
            .Enum([
                .Number(.Bool),
                .Number(.Double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool and Double should be merged to enum containing Bool and Double numbers")
    }

    func testArrayOfMixedBoolIntAndDouble() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Double(10),
            true,
            Int(10)
        ))
        let expectedResult: ModelParser.FieldType = .List(
            .Enum([
                .Number(.Bool),
                .Number(.Double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool, Int and Double should be merged to enum containing Bool and Double numbers")
    }
    
    func testArrayOfObjectsWithMissingField() throws {
        let type1 = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            Dictionary<String, Any>(dictionaryLiteral: ("string", "Test"))
        ))
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "string", type: .Optional(.Text))
            ])
        )
        XCTAssertEqual(type1, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
        
        let type2 = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(dictionaryLiteral: ("string", "Test")),
            Dictionary<String, Any>()
        ))
        XCTAssertEqual(type2, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
    }
    
    func testArrayOfObjectsWithMixedTypesAndOptional() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", NSNull())),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", "string")),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Double(10))
        )))
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "mixed", type: .Optional(
                    .Enum([
                        .Text,
                        .Number(.Double)
                    ])
                ))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }

    func testArrayObjectWithArrayFieldOfUnknownTypeAndStrings() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>())),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: "String"))
        )))
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "mixed", type: .List(.Text))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }
    
    func testArrayObjectWithArrayFieldOfIntsStringsAndDoubles() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: Int(10)))),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: "String"))),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: Double(10)))
        )))
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "mixed", type: .List(
                    .Enum([
                        .Number(.Double),
                        .Text
                    ])
                ))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }

    func testArrayObjectWithMixedFieldOfMixedArraysAndInt() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: "String"))),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Int(10))),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: Double(10)))),
            Dictionary<String, Any>(dictionaryLiteral: ("mixed", Array<Any>(arrayLiteral: NSNull())))
        ))
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "mixed", type: .Enum([
                    .List(
                        .Optional(
                            .Enum([
                                .Text,
                                .Number(.Double)
                            ])
                        )
                    ),
                    .Number(.Int)
                ]))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }
    
    
    func testUnsupported() {
        var error: ErrorType? = nil
        do {
            try parser.decode(NSObject())
        } catch let e {
            error = e
        }
        XCTAssertNotNil(error)
    }
    
    func testTransformAllFieldsToOptional() {
        let type: ModelParser.FieldType = .Object([
            .init(name: "innerObject", type: .Object([
                .init(name: "innerText", type: .Text),
            ])),
            .init(name: "list", type: .List(
                    .Object([
                        .init(name: "insideList", type: .Text)
                    ])
                )
            ),
            .init(name: "text", type: .Text),
            .init(name: "number", type: .Number(.Int)),
            .init(name: "enum", type: .Enum([
                    .Object([
                        .init(name: "textInEnum", type: .Text)
                    ]),
                    .Number(.Float)
                ])
            ),
            .init(name: "unknown", type: .Unknown),
            .init(name: "optionalText", type: .Optional(.Text)),
            .init(name: "optionalObject", type: .Optional(.Object([
                .init(name: "textInsideOptionalObject", type: .Text)
            ])))
        ])
        
        let expectedResult: ModelParser.FieldType = .Object([
            .init(name: "innerObject", type: .Optional(.Object([
                .init(name: "innerText", type: .Optional(.Text)),
            ]))),
            .init(name: "list", type: .Optional(.List(
                    .Object([
                        .init(name: "insideList", type: .Optional(.Text))
                    ])
                ))
            ),
            .init(name: "text", type: .Optional(.Text)),
            .init(name: "number", type: .Optional(.Number(.Int))),
            .init(name: "enum", type: .Optional(.
                Enum([
                    .Object([
                        .init(name: "textInEnum", type: .Optional(.Text))
                    ]),
                    .Number(.Float)
                ])
            )),
            .init(name: "unknown", type: .Optional(.Unknown)),
            .init(name: "optionalText", type: .Optional(.Text)),
            .init(name: "optionalObject", type: .Optional(.Object([
                .init(name: "textInsideOptionalObject", type: .Optional(.Text))
            ])))
        ])
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelList() {
        let type: ModelParser.FieldType = .List(.Text)
        let expectedResult: ModelParser.FieldType = .List(.Text)
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelEnum() {
        let type: ModelParser.FieldType = .Enum([.Text, .Number(.Int)])
        let expectedResult: ModelParser.FieldType = .Enum([.Text, .Number(.Int)])
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
}
