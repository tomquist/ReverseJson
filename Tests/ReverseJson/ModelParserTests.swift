//
//  ReverseJsonTests.swift
//  ReverseJsonTests
//
//  Created by Tom Quist on 28.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest
@testable import ReverseJson

class ReverseJsonTests: XCTestCase, XCTestCaseProvider {
    
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
        ]
    }
    
    var parser: ModelParser!
    
    override func setUp() {
        super.setUp()
        parser = ModelParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
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
    
    func testString() {
        let type = try! parser.decode("Simple string")
        XCTAssertEqual(type, ModelParser.FieldType.Text)
    }
    
    func testInt() {
        let type = try! parser.decode(10)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Int))
    }
    
    func testDouble() {
        let type = try! parser.decode(10.0)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Double))
    }
    
    func testFloat() {
        let type = try! parser.decode(Float(10.0))
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Float))
    }
    
    func testBool() {
        let type = try! parser.decode(true)
        XCTAssertEqual(type, ModelParser.FieldType.Number(.Bool))
    }
    
    func testEmptyObject() {
        let type = try! parser.decode([:])
        XCTAssertEqual(type, ModelParser.FieldType.Object([]))
    }
    
    func testEmptyArray() {
        let type = try! parser.decode([])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Unknown))
    }

    func testStringArray() {
        let type = try! parser.decode([
            "Test",
            "123"
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Text))
    }
    
    func testIntArray() {
        let type = try! parser.decode([
            Int(10),
            Int(20)
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Number(.Int)))
    }

    func testOptionalStringArray() {
        let type = try! parser.decode([
            "Test",
            NSNull()
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Text)))
    }
    
    func testNullArray() {
        let type = try! parser.decode([
            NSNull()
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Unknown)))
    }

    func testSingleFieldObject() {
        let type = try! parser.decode([
            "string":"Test"
        ])
        XCTAssertEqual(type, ModelParser.FieldType.Object([ModelParser.ObjectField(name: "string", type: .Text)]))
    }
    
    func testThreeFieldsObject() {
        let type = try! parser.decode([
            "string":"Test",
            "integer": 123,
            "object": [:]
        ])
        let expectedType: ModelParser.FieldType = .Object([
            .init(name: "string", type: .Text),
            .init(name: "integer", type: .Number(.Int)),
            .init(name: "object", type: .Object([]))
        ])
        XCTAssertEqual(type, expectedType)
    }

    func testArrayOfEmptyObject() {
        let type = try! parser.decode([
            [:],
            [:]
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Object([])))
    }
    
    func testArrayOfEmptyOptionalObject() {
        let type = try! parser.decode([
            [:],
            NSNull()
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Optional(.Object([]))))
    }
    
    func testArrayOfMixedIntFloatAndDouble() {
        let type = try! parser.decode([
            Int(10),
            Double(10),
            Float(10)
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Number(.Double)), "Mixed number types with at least one Double should be merged to Double")
    }
    
    func testArrayOfMixedIntAndFloat() {
        let type = try! parser.decode([
            Int(10),
            Float(10)
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Number(.Float)
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Int and Float should be merged to Float")
    }

    func testArrayOfMixedBoolAndDouble() {
        let type = try! parser.decode([
            Double(10),
            true
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Enum([
                .Number(.Bool),
                .Number(.Double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool and Double should be merged to enum containing Bool and Double numbers")
    }

    func testArrayOfMixedBoolIntAndDouble() {
        let type = try! parser.decode([
            Double(10),
            true,
            Int(10)
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Enum([
                .Number(.Bool),
                .Number(.Double)
            ])
        )
        XCTAssertEqual(type, expectedResult, "Mixed number types with Bool, Int and Double should be merged to enum containing Bool and Double numbers")
    }
    
    func testArrayOfObjectsWithMissingField() {
        let type1 = try! parser.decode([
            [:],
            ["string":"Test"]
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "string", type: .Optional(.Text))
            ])
        )
        XCTAssertEqual(type1, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
        
        let type2 = try! parser.decode([
            ["string":"Test"],
            [:]
        ])
        XCTAssertEqual(type2, expectedResult, "List of objects where in one object a field is missing, should result in a object with an optional field type")
    }
    
    func testArrayOfObjectsWithMixedTypesAndOptional() {
        let type = try! parser.decode([
            ["mixed":NSNull()       ],
            ["mixed":"string"       ],
            ["mixed":Double(10)     ],
        ])
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

    func testArrayObjectWithArrayFieldOfUnknownTypeAndStrings() {
        let type = try! parser.decode([
            ["mixed":[]             ],
            ["mixed":["String"]     ],
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "mixed", type: .List(.Text))
            ])
        )
        XCTAssertEqual(type, expectedResult)
    }
    
    func testArrayObjectWithArrayFieldOfIntsStringsAndDoubles() {
        let type = try! parser.decode([
            ["mixed":[Int(10)]      ],
            ["mixed":["String"]     ],
            ["mixed":[Double(10)]   ],
        ])
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

    func testArrayObjectWithMixedFieldOfMixedArraysAndInt() {
        let type = try! parser.decode([
            ["mixed":["String"]     ],
            ["mixed":Int(10)        ],
            ["mixed":[Double(10)]   ],
            ["mixed":[NSNull()]     ],
        ])
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
}
