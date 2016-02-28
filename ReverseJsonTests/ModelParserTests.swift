//
//  ReverseJsonTests.swift
//  ReverseJsonTests
//
//  Created by Tom Quist on 28.02.16.
//  Copyright © 2016 Tom Quist. All rights reserved.
//

import XCTest

class ReverseJsonTests: XCTestCase {
    
    var parser: ModelParser!
    
    override func setUp() {
        super.setUp()
        parser = ModelParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
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
    
    func testEmptyStruct() {
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

    func testSingleFieldStruct() {
        let type = try! parser.decode([
            "string":"Test"
        ])
        XCTAssertEqual(type, ModelParser.FieldType.Object([ModelParser.ObjectField(name: "string", type: .Text)]))
    }
    
    func testTwoFieldsStruct() {
        let type = try! parser.decode([
            "string":"Test",
            "integer": 123
        ])
        XCTAssertEqual(type, ModelParser.FieldType.Object([.init(name: "string", type: .Text), .init(name: "integer", type: .Number(.Int))]))
    }

    func testArrayOfEmptyStruct() {
        let type = try! parser.decode([
            [:],
            [:]
        ])
        XCTAssertEqual(type, ModelParser.FieldType.List(.Object([])))
    }
    
    func testArrayOfEmptyOptionalStruct() {
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
    
    func testArrayOfStructsWithMissingField() {
        let type1 = try! parser.decode([
            [:],
            ["string":"Test"]
        ])
        let expectedResult: ModelParser.FieldType = .List(
            .Object([
                .init(name: "string", type: .Optional(.Text))
            ])
        )
        XCTAssertEqual(type1, expectedResult, "List of structs where in one struct a field is missing, should result in a struct with an optional field type")
        
        let type2 = try! parser.decode([
            ["string":"Test"],
            [:]
        ])
        XCTAssertEqual(type2, expectedResult, "List of structs where in one struct a field is missing, should result in a struct with an optional field type")
    }
    
    func testArrayOfStructsWithMixedTypesAndOptional() {
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

    func testArrayStructWithArrayFieldOfUnknownTypeAndStrings() {
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
    
    func testArrayStructWithArrayFieldOfIntsStringsAndDoubles() {
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

    func testArrayStructWithMixedFieldOfMixedArraysAndInt() {
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
}
