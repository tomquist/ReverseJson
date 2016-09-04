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

class ModelParserTest: XCTestCase {
    
    static var allTests: [(String, (ModelParserTest) -> () throws -> Void)] {
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
            ("testJsonBool", testJsonBool),
            ("testJsonInt", testJsonInt),
            ("testJsonDouble", testJsonDouble),
            ("testJsonString", testJsonString),
            ("testJsonEmptyObject", testJsonEmptyObject),
            ("testJsonEmptyArray", testJsonEmptyArray),
            ("testJsonNullArray", testJsonNullArray),
            ("testJsonStringArray", testJsonStringArray),
            ("testJsonIntArray", testJsonIntArray),
            ("testJsonOptionalStringArray", testJsonOptionalStringArray),
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
    
    func XCTAsserEqualFieldType(_ fieldType1: ModelParser.FieldType, _ fieldType2: ModelParser.FieldType) {
        XCTAssertEqual(fieldType1, fieldType2)
    }
    func XCTAsserNotEqualFieldType(_ fieldType1: ModelParser.FieldType, _ fieldType2: ModelParser.FieldType) {
        XCTAssertNotEqual(fieldType1, fieldType2)
    }
    
    func testEqualTypeUnknown() {
        XCTAsserEqualFieldType(.unknown, .unknown)
        XCTAsserNotEqualFieldType(.unknown, .number(.int))
    }
    
    func testEqualTypeText() {
        XCTAsserEqualFieldType(ModelParser.FieldType.text, .text)
        XCTAsserNotEqualFieldType(.text, .number(.int))
    }
    
    func testEqualNumberTypes() {
        XCTAssertEqual(ModelParser.NumberType.int, ModelParser.NumberType.int)
        XCTAssertEqual(ModelParser.NumberType.float, ModelParser.NumberType.float)
        XCTAssertEqual(ModelParser.NumberType.bool, ModelParser.NumberType.bool)
        XCTAssertEqual(ModelParser.NumberType.double, ModelParser.NumberType.double)
        XCTAssertNotEqual(ModelParser.NumberType.int, ModelParser.NumberType.double)
        XCTAssertNotEqual(ModelParser.NumberType.float, ModelParser.NumberType.double)
    }

    func testEqualTypeNumber() {
        XCTAsserEqualFieldType(.number(.int), .number(.int))
        XCTAsserNotEqualFieldType(.number(.int), .text)
        XCTAsserNotEqualFieldType(.number(.int), .number(.double))
    }
    
    func testEqualTypeList() {
        XCTAsserEqualFieldType(.list(.text), .list(.text))
        XCTAsserNotEqualFieldType(.list(.text), .text)
        XCTAsserNotEqualFieldType(.list(.text), .list(.number(.int)))
    }
    
    func testEqualTypeOptional() {
        XCTAsserEqualFieldType(.optional(.text), .optional(.text))
        XCTAsserNotEqualFieldType(.optional(.text), .text)
        XCTAsserNotEqualFieldType(.optional(.text), .list(.text))
        XCTAsserNotEqualFieldType(.optional(.text), .optional(.number(.int)))
    }
    
    func testEqualTypeObject() {
        XCTAsserEqualFieldType(.object([]), .object([]))
        XCTAsserEqualFieldType(.object([.init(name: "object", type: .text)]), .object([.init(name: "object", type: .text)]))
        XCTAsserEqualFieldType(.object([
            .init(name: "object", type: .text),
            .init(name: "int", type: .number(.int)),
        ]), .object([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.object([
            .init(name: "object", type: .text),
            .init(name: "int", type: .number(.int)),
        ]), .object([
            .init(name: "int", type: .text),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.object([
            .init(name: "object", type: .text),
            .init(name: "integer", type: .number(.int)),
        ]), .object([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.object([
            .init(name: "object", type: .text),
        ]), .object([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.object([.init(name: "object", type: .text)]), .object([.init(name: "text", type: .text)]))
        XCTAsserNotEqualFieldType(.object([.init(name: "object", type: .text)]), .text)
    }
    
    func testEqualTypeEnum() {
        XCTAsserEqualFieldType(.`enum`([]), .enum([]))
        XCTAsserEqualFieldType(.enum([.text]), .enum([.text]))
        XCTAsserEqualFieldType(.enum([
            .text,
            .number(.int),
        ]), .enum([
            .number(.int),
            .text,
        ]))
        XCTAsserNotEqualFieldType(.enum([
            .text,
            .number(.int),
        ]), .enum([
            .text
        ]))
        XCTAsserNotEqualFieldType(.enum([.text]), .enum([.number(.int)]))
        XCTAsserNotEqualFieldType(.enum([.text]), .text)
    }
    
    func testString() throws {
        let type = try parser.decode("Simple string")
        XCTAssertEqual(type, ModelParser.FieldType.text)
    }
    
    func testInt() throws {
        let type = try parser.decode(10)
        XCTAssertEqual(type, ModelParser.FieldType.number(.int))
    }
    
    func testJsonIntExponential() throws {
        let jsonValue = "1E3"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.number(.double))
    }
    
    func testJsonIntNegativeExponential() throws {
        let jsonValue = "1E-3"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.number(.double))
    }
    
    func testDouble() throws {
        let type = try parser.decode(10.0)
        XCTAssertEqual(type, ModelParser.FieldType.number(.double))
    }
    
    func testFloat() throws {
        let type = try parser.decode(Float(10.0))
        XCTAssertEqual(type, ModelParser.FieldType.number(.float))
    }
    
    func testBool() throws {
        let type = try parser.decode(true)
        XCTAssertEqual(type, ModelParser.FieldType.number(.bool))
    }
    
    private func data(from jsonValue: String) throws -> Any {
        let data = "{\"value\":\(jsonValue)}".data(using: .utf8)!
        
        let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return jsonObj["value"]!
    }
    
    func testJsonBool() throws {
        let jsonValue = "true"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.number(.bool))
    }
    
    func testJsonInt() throws {
        let jsonValue = "1"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.number(.int))
    }
    
    func testJsonDouble() throws {
        let jsonValue = "1.2"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.number(.double))
    }

    func testJsonString() throws {
        let jsonValue = "\"Simple string\""
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.text)
    }
    
    func testJsonEmptyObject() throws {
        let jsonValue = "{}"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.object([]))
    }
    
    func testJsonEmptyArray() throws {
        let jsonValue = "[]"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.list(.unknown))
    }
    
    func testJsonNullArray() throws {
        let jsonValue = "[null, null]"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.unknown)))
    }
    
    func testJsonStringArray() throws {
        let jsonValue = "[\"Test\", \"123\"]"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.list(.text))
    }
    
    func testJsonIntArray() throws {
        let jsonValue = "[1,2,3]"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.list(.number(.int)))
    }
    
    func testJsonOptionalStringArray() throws {
        let jsonValue = "[\"Test\", \"123\", null]"
        let type = try parser.decode(try data(from: jsonValue))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.text)))
    }
    
    func testEmptyObject() throws {
        let type = try parser.decode(Dictionary<String, Any>())
        XCTAssertEqual(type, ModelParser.FieldType.object([]))
    }
    
    func testEmptyArray() throws {
        let type = try parser.decode(Array<Any>())
        XCTAssertEqual(type, ModelParser.FieldType.list(.unknown))
    }

    func testStringArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            "Test",
            "123"
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.text))
    }
    
    func testIntArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Int(20)
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.number(.int)))
    }

    func testOptionalStringArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            "Test",
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.text)))
    }
    
    func testNullArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.unknown)))
    }

    func testNilArray() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Optional<Any>.none
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.unknown)))
    }
    
    func testSingleFieldObject() throws {
        let type = try parser.decode(Dictionary<String, Any>(dictionaryLiteral:
            ("string", "Test")
        ))
        XCTAssertEqual(type, ModelParser.FieldType.object([ModelParser.ObjectField(name: "string", type: .text)]))
    }
    
    func testThreeFieldsObject() throws {
        let type = try parser.decode(Dictionary<String, Any>(dictionaryLiteral:
            ("string", "Test"),
            ("integer", 123),
            ("object", Dictionary<String, Any>())
        ))
        let expectedType: ModelParser.FieldType = .object([
            .init(name: "string", type: .text),
            .init(name: "integer", type: .number(.int)),
            .init(name: "object", type: .object([]))
        ])
        XCTAssertEqual(type, expectedType)
    }

    func testArrayOfEmptyObject() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            Dictionary<String, Any>()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.object([])))
    }
    
    func testArrayOfEmptyOptionalObject() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            NSNull()
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.optional(.object([]))))
    }
    
    func testArrayOfMixedIntFloatAndDouble() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Double(10),
            Float(10)
        ))
        XCTAssertEqual(type, ModelParser.FieldType.list(.number(.double)), "Mixed number types with at least one Double should be merged to Double")
    }
    
    func testArrayOfMixedIntAndFloat() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Int(10),
            Float(10)
        ))
        let expectedResult: ModelParser.FieldType = .list(
            .number(.float)
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Int and Float should be merged to Float")
    }

    func testArrayOfMixedBoolAndDouble() throws {
        let type = try parser.decode(Array<Any>(arrayLiteral:
            Double(10),
            true
        ))
        let expectedResult: ModelParser.FieldType = .list(
            .enum([
                .number(.bool),
                .number(.double)
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
        let expectedResult: ModelParser.FieldType = .list(
            .enum([
                .number(.bool),
                .number(.double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool, Int and Double should be merged to enum containing Bool and Double numbers")
    }
    
    func testArrayOfObjectsWithMissingField() throws {
        let type1 = try parser.decode(Array<Any>(arrayLiteral:
            Dictionary<String, Any>(),
            Dictionary<String, Any>(dictionaryLiteral: ("string", "Test"))
        ))
        let expectedResult: ModelParser.FieldType = .list(
            .object([
                .init(name: "string", type: .optional(.text))
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
        let expectedResult: ModelParser.FieldType = .list(
            .object([
                .init(name: "mixed", type: .optional(
                    .enum([
                        .text,
                        .number(.double)
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
        let expectedResult: ModelParser.FieldType = .list(
            .object([
                .init(name: "mixed", type: .list(.text))
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
        let expectedResult: ModelParser.FieldType = .list(
            .object([
                .init(name: "mixed", type: .list(
                    .enum([
                        .number(.double),
                        .text
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
        let expectedResult: ModelParser.FieldType = .list(
            .object([
                .init(name: "mixed", type: .enum([
                    .list(
                        .optional(
                            .enum([
                                .text,
                                .number(.double)
                            ])
                        )
                    ),
                    .number(.int)
                ]))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }
    
    
    func testUnsupported() {
        var error: Error? = nil
        do {
            let _ = try parser.decode(NSObject())
        } catch let e {
            error = e
        }
        XCTAssertNotNil(error)
    }
    
    func testTransformAllFieldsToOptional() {
        let type: ModelParser.FieldType = .object([
            .init(name: "innerObject", type: .object([
                .init(name: "innerText", type: .text),
            ])),
            .init(name: "list", type: .list(
                    .object([
                        .init(name: "insideList", type: .text)
                    ])
                )
            ),
            .init(name: "text", type: .text),
            .init(name: "number", type: .number(.int)),
            .init(name: "enum", type: .enum([
                    .object([
                        .init(name: "textInEnum", type: .text)
                    ]),
                    .number(.float)
                ])
            ),
            .init(name: "unknown", type: .unknown),
            .init(name: "optionalText", type: .optional(.text)),
            .init(name: "optionalObject", type: .optional(.object([
                .init(name: "textInsideOptionalObject", type: .text)
            ])))
        ])
        
        let expectedResult: ModelParser.FieldType = .object([
            .init(name: "innerObject", type: .optional(.object([
                .init(name: "innerText", type: .optional(.text)),
            ]))),
            .init(name: "list", type: .optional(.list(
                    .object([
                        .init(name: "insideList", type: .optional(.text))
                    ])
                ))
            ),
            .init(name: "text", type: .optional(.text)),
            .init(name: "number", type: .optional(.number(.int))),
            .init(name: "enum", type: .optional(.
                enum([
                    .object([
                        .init(name: "textInEnum", type: .optional(.text))
                    ]),
                    .number(.float)
                ])
            )),
            .init(name: "unknown", type: .optional(.unknown)),
            .init(name: "optionalText", type: .optional(.text)),
            .init(name: "optionalObject", type: .optional(.object([
                .init(name: "textInsideOptionalObject", type: .optional(.text))
            ])))
        ])
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelList() {
        let type: ModelParser.FieldType = .list(.text)
        let expectedResult: ModelParser.FieldType = .list(.text)
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelEnum() {
        let type: ModelParser.FieldType = .enum([.text, .number(.int)])
        let expectedResult: ModelParser.FieldType = .enum([.text, .number(.int)])
        
        let transformedResult = ModelParser.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
}
