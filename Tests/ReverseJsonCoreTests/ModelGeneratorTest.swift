
import XCTest
import Foundation
import CoreJSON
import CoreJSONLiterals
@testable import ReverseJsonCore

class ModelGeneratorTest: XCTestCase {
    
    var parser = ModelGenerator()
    
    func XCTAsserEqualFieldType(_ fieldType1: FieldType, _ fieldType2: FieldType) {
        XCTAssertEqual(fieldType1, fieldType2)
    }
    func XCTAsserNotEqualFieldType(_ fieldType1: FieldType, _ fieldType2: FieldType) {
        XCTAssertNotEqual(fieldType1, fieldType2)
    }
    
    func testEqualTypeUnknown() {
        XCTAsserEqualFieldType(.unnamedUnknown, .unnamedUnknown)
        XCTAsserNotEqualFieldType(.unnamedUnknown, .number(.int))
    }
    
    func testEqualTypeText() {
        XCTAsserEqualFieldType(FieldType.text, .text)
        XCTAsserNotEqualFieldType(.text, .number(.int))
    }
    
    func testEqualNumberTypes() {
        XCTAssertEqual(NumberType.int, NumberType.int)
        XCTAssertEqual(NumberType.float, NumberType.float)
        XCTAssertEqual(NumberType.bool, NumberType.bool)
        XCTAssertEqual(NumberType.double, NumberType.double)
        XCTAssertNotEqual(NumberType.int, NumberType.double)
        XCTAssertNotEqual(NumberType.float, NumberType.double)
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
        XCTAsserEqualFieldType(.unnamedObject([]), .unnamedObject([]))
        XCTAsserEqualFieldType(.unnamedObject([.init(name: "object", type: .text)]), .unnamedObject([.init(name: "object", type: .text)]))
        XCTAsserEqualFieldType(.unnamedObject([
            .init(name: "object", type: .text),
            .init(name: "int", type: .number(.int)),
        ]), .unnamedObject([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.unnamedObject([
            .init(name: "object", type: .text),
            .init(name: "int", type: .number(.int)),
        ]), .unnamedObject([
            .init(name: "int", type: .text),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.unnamedObject([
            .init(name: "object", type: .text),
            .init(name: "integer", type: .number(.int)),
        ]), .unnamedObject([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.unnamedObject([
            .init(name: "object", type: .text),
        ]), .unnamedObject([
            .init(name: "int", type: .number(.int)),
            .init(name: "object", type: .text),
        ]))
        XCTAsserNotEqualFieldType(.unnamedObject([.init(name: "object", type: .text)]), .unnamedObject([.init(name: "text", type: .text)]))
        XCTAsserNotEqualFieldType(.unnamedObject([.init(name: "object", type: .text)]), .text)
    }
    
    func testEqualTypeEnum() {
        XCTAsserEqualFieldType(.unnamedEnum([]), .unnamedEnum([]))
        XCTAsserEqualFieldType(.unnamedEnum([.text]), .unnamedEnum([.text]))
        XCTAsserEqualFieldType(.unnamedEnum([
            .text,
            .number(.int),
        ]), .unnamedEnum([
            .number(.int),
            .text,
        ]))
        XCTAsserNotEqualFieldType(.unnamedEnum([
            .text,
            .number(.int),
        ]), .unnamedEnum([
            .text
        ]))
        XCTAsserNotEqualFieldType(.unnamedEnum([.text]), .unnamedEnum([.number(.int)]))
        XCTAsserNotEqualFieldType(.unnamedEnum([.text]), .text)
    }
    
    func testString() throws {
        let type = parser.decode("Simple string")
        XCTAssertEqual(type, FieldType.text)
    }
    
    func testInt() throws {
        let type = parser.decode(10)
        XCTAssertEqual(type, FieldType.number(.int))
    }
    
    func testUInt() throws {
        let type = parser.decode(.number(.uint(10)))
        XCTAssertEqual(type, FieldType.number(.int))
    }
    
    func testDouble() throws {
        let type = parser.decode(10.0)
        XCTAssertEqual(type, FieldType.number(.double))
    }
    
    func testFloat() throws {
        let type = parser.decode(.number(.float(10.0)))
        XCTAssertEqual(type, FieldType.number(.float))
    }
    
    func testBool() throws {
        let type = parser.decode(true)
        XCTAssertEqual(type, FieldType.number(.bool))
    }
    
    private func data(from jsonValue: String) throws -> Any {
        let data = "{\"value\":\(jsonValue)}".data(using: .utf8)!
        
        let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return jsonObj["value"]!
    }
    
    func testEmptyObject() throws {
        let type = parser.decode([:])
        XCTAssertEqual(type, FieldType.unnamedObject([]))
    }
    
    func testEmptyArray() throws {
        let type = parser.decode([])
        XCTAssertEqual(type, FieldType.list(.unnamedUnknown))
    }

    func testStringArray() throws {
        let type = parser.decode([
            "Test",
            "123"
        ])
        XCTAssertEqual(type, FieldType.list(.text))
    }
    
    func testIntArray() throws {
        let type = parser.decode([
            10,
            20
        ])
        XCTAssertEqual(type, FieldType.list(.number(.int)))
    }

    func testOptionalStringArray() throws {
        let type = parser.decode([
            "Test",
            nil
        ])
        XCTAssertEqual(type, FieldType.list(.optional(.text)))
    }
    
    func testNullArray() throws {
        let type = parser.decode([
            nil
        ])
        XCTAssertEqual(type, FieldType.list(.optional(.unnamedUnknown)))
    }

    func testSingleFieldObject() throws {
        let type = parser.decode([
            "string": "Test"
        ])
        XCTAssertEqual(type, FieldType.unnamedObject([ObjectField(name: "string", type: .text)]))
    }
    
    func testThreeFieldsObject() throws {
        let type = parser.decode([
            "string": "Test",
            "integer": 123,
            "object": [:]
        ])
        let expectedType: FieldType = .unnamedObject([
            .init(name: "string", type: .text),
            .init(name: "integer", type: .number(.int)),
            .init(name: "object", type: .unnamedObject([]))
        ])
        XCTAssertEqual(type, expectedType)
    }

    func testArrayOfEmptyObject() throws {
        let type = parser.decode([
            [:],
            [:]
        ])
        XCTAssertEqual(type, FieldType.list(.unnamedObject([])))
    }
    
    func testArrayOfEmptyOptionalObject() throws {
        let type = parser.decode([
            [:],
            nil
        ])
        XCTAssertEqual(type, FieldType.list(.optional(.unnamedObject([]))))
    }
    
    func testArrayOfMixedIntFloatAndDouble() throws {
        let type = parser.decode([
            10,
            10.0,
            JSON.number(.float(10))
        ])
        XCTAssertEqual(type, FieldType.list(.number(.double)), "Mixed number types with at least one Double should be merged to Double")
    }
    
    func testArrayOfMixedIntAndFloat() throws {
        let type = parser.decode([
            10,
            .number(.float(10.0))
        ])
        let expectedResult: FieldType = .list(
            .number(.float)
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Int and Float should be merged to Float")
    }

    func testArrayOfMixedBoolAndDouble() throws {
        let type = parser.decode([
            10.0,
            true
        ])
        let expectedResult: FieldType = .list(
            .unnamedEnum([
                .number(.bool),
                .number(.double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool and Double should be merged to enum containing Bool and Double numbers")
    }

    func testArrayOfMixedBoolIntAndDouble() throws {
        let type = parser.decode([
            10.0,
            true,
            10
        ])
        let expectedResult: FieldType = .list(
            .unnamedEnum([
                .number(.bool),
                .number(.double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool, Int and Double should be merged to enum containing Bool and Double numbers")
    }
    
    func testArrayOfObjectsWithMissingField() throws {
        let type1 = parser.decode([
            [:],
            ["string": "Test"]
        ])
        let expectedResult: FieldType = .list(
            .unnamedObject([
                .init(name: "string", type: .optional(.text))
            ])
        )
        XCTAssertEqual(type1, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
        
        let type2 = parser.decode([
            ["string": "Test"],
            [:]
        ])
        XCTAssertEqual(type2, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
    }
    
    func testArrayOfObjectsWithMixedTypesAndOptional() throws {
        let type = parser.decode([
            ["mixed": nil],
            ["mixed": "string"],
            ["mixed": .number(.double(10))]
        ])
        let expectedResult: FieldType = .list(
            .unnamedObject([
                .init(name: "mixed", type: .optional(
                    .unnamedEnum([
                        .text,
                        .number(.double)
                    ])
                ))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }

    func testArrayObjectWithArrayFieldOfUnknownTypeAndStrings() throws {
        let type = parser.decode([
            ["mixed": []],
            ["mixed": ["String"]]
        ])
        let expectedResult: FieldType = .list(
            .unnamedObject([
                .init(name: "mixed", type: .list(.text))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }
    
    func testArrayObjectWithArrayFieldOfIntsStringsAndDoubles() throws {
        let type = parser.decode([
            ["mixed": [.number(.int(10))]],
            ["mixed": ["String"]],
            ["mixed": [.number(.double(10))]]
        ])
        let expectedResult: FieldType = .list(
            .unnamedObject([
                .init(name: "mixed", type: .list(
                    .unnamedEnum([
                        .number(.double),
                        .text
                    ])
                ))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }

    func testArrayObjectWithMixedFieldOfMixedArraysAndInt() throws {
        let type = parser.decode([
            ["mixed": ["String"]],
            ["mixed": .number(.int(10))],
            ["mixed": [.number(.double(10))]],
            ["mixed": [nil]]
        ])
        let expectedResult: FieldType = .list(
            .unnamedObject([
                .init(name: "mixed", type: .unnamedEnum([
                    .list(
                        .optional(
                            .unnamedEnum([
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
    
    
    func testTransformAllFieldsToOptional() {
        let type: FieldType = .unnamedObject([
            .init(name: "innerObject", type: .unnamedObject([
                .init(name: "innerText", type: .text),
            ])),
            .init(name: "list", type: .list(
                    .unnamedObject([
                        .init(name: "insideList", type: .text)
                    ])
                )
            ),
            .init(name: "text", type: .text),
            .init(name: "number", type: .number(.int)),
            .init(name: "enum", type: .unnamedEnum([
                    .unnamedObject([
                        .init(name: "textInEnum", type: .text)
                    ]),
                    .number(.float)
                ])
            ),
            .init(name: "unknown", type: .unnamedUnknown),
            .init(name: "optionalText", type: .optional(.text)),
            .init(name: "optionalObject", type: .optional(.unnamedObject([
                .init(name: "textInsideOptionalObject", type: .text)
            ])))
        ])
        
        let expectedResult: FieldType = .unnamedObject([
            .init(name: "innerObject", type: .optional(.unnamedObject([
                .init(name: "innerText", type: .optional(.text)),
            ]))),
            .init(name: "list", type: .optional(.list(
                    .unnamedObject([
                        .init(name: "insideList", type: .optional(.text))
                    ])
                ))
            ),
            .init(name: "text", type: .optional(.text)),
            .init(name: "number", type: .optional(.number(.int))),
            .init(name: "enum", type: .optional(
                .unnamedEnum([
                    .unnamedObject([
                        .init(name: "textInEnum", type: .optional(.text))
                    ]),
                    .number(.float)
                ])
            )),
            .init(name: "unknown", type: .optional(.unnamedUnknown)),
            .init(name: "optionalText", type: .optional(.text)),
            .init(name: "optionalObject", type: .optional(.unnamedObject([
                .init(name: "textInsideOptionalObject", type: .optional(.text))
            ])))
        ])
        
        let transformedResult = ModelGenerator.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelList() {
        let type: FieldType = .list(.text)
        let expectedResult: FieldType = .list(.text)
        
        let transformedResult = ModelGenerator.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
    
    func testTransformAllFieldsToOptionalWithToplevelEnum() {
        let type: FieldType = .unnamedEnum([.text, .number(.int)])
        let expectedResult: FieldType = .unnamedEnum([.text, .number(.int)])
        
        let transformedResult = ModelGenerator.transformAllFieldsToOptional(type)
        XCTAssertEqual(expectedResult, transformedResult)
    }
}

#if os(Linux)
extension ModelGeneratorTest {
    static var allTests: [(String, (ModelGeneratorTest) -> () throws -> Void)] {
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
            ("testUInt", testUInt),
            ("testIntArray", testIntArray),
            ("testNullArray", testNullArray),
            ("testOptionalStringArray", testOptionalStringArray),
            ("testSingleFieldObject", testSingleFieldObject),
            ("testString", testString),
            ("testStringArray", testStringArray),
            ("testThreeFieldsObject", testThreeFieldsObject),
            ("testTransformAllFieldsToOptional", testTransformAllFieldsToOptional),
            ("testTransformAllFieldsToOptionalWithToplevelList", testTransformAllFieldsToOptionalWithToplevelList),
            ("testTransformAllFieldsToOptionalWithToplevelEnum", testTransformAllFieldsToOptionalWithToplevelEnum)
        ]
    }
}
#endif
