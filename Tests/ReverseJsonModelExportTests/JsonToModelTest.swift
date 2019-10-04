
import XCTest
import ReverseJsonCore
@testable import ReverseJsonModelExport

class JsonToModelTest: XCTestCase {
    
    func testSimpleString() {
        let expected: FieldType = .text
        var type = try! FieldType(json: "string")
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "string",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testSimpleInt() {
        let expected: FieldType = .number(.int)
        var type = try! FieldType(json: "int")
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "int",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testOptionalInt() {
        let expected: FieldType = .optional(.number(.int))
        var type = try! FieldType(json: ["type": "int?"])
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "int",
            "isOptional": true
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testSimpleFloat() {
        let expected: FieldType = .number(.float)
        var type = try! FieldType(json: "float")
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "float",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testSimpleDouble() {
        let expected: FieldType = .number(.double)
        var type = try! FieldType(json: "double")
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "double",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testSimpleBool() {
        let expected: FieldType = .number(.bool)
        var type = try! FieldType(json: "bool")
        XCTAssertEqual(type, expected)
        type = try! FieldType(json: [
            "type": "bool",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testEmptyObject() {
        let expected: FieldType = .unnamedObject([])
        let type = try! FieldType(json: "object")
        XCTAssertEqual(type, expected)
    }
    
    func testNamedEmptyObject() {
        let expected: FieldType = .object(name: "Object", [])
        let type = try! FieldType(json: [
            "type": "object",
            "name": "Object"
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testUnknown() {
        let expected: FieldType = .unnamedUnknown
        let type = try! FieldType(json: "any")
        XCTAssertEqual(type, expected)
    }
    
    func testNamedEmptyUnknown() {
        let expected: FieldType = .unknown(name: "Unknown")
        let type = try! FieldType(json: [
            "type": "any",
            "name": "Unknown"
        ])
        XCTAssertEqual(type, expected)
    }

    
    func testTextList() {
        let expected: FieldType = .list(.text)
        let type = try! FieldType(json: [
            "type": "list",
            "content": "string"
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testListWithoutContent() {
        let expected: FieldType = .list(.unnamedUnknown)
        let type = try! FieldType(json: [
            "type": "list",
        ])
        XCTAssertEqual(type, expected)
    }

    
    func testListOfTextList() {
        let expected: FieldType = .list(.list(.text))
        let type = try! FieldType(json: [
            "type": "list",
            "content": [
                "type": "list",
                "content": "string"
            ]
        ])
        XCTAssertEqual(type, expected)
    }

    func testOptionalUnknown() {
        let expected: FieldType = .optional(.unnamedUnknown)
        let type = try! FieldType(json: "any?")
        XCTAssertEqual(type, expected)
    }
    
    func testListOfUnknown() {
        let expected: FieldType = .list(.unnamedUnknown)
        let type = try! FieldType(json: [
            "type": "list",
            "content": "any"
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testOptionalText() {
        let expected: FieldType = .optional(.text)
        let type = try! FieldType(json: "string?")
        XCTAssertEqual(type, expected)
    }
    
    func testListOfEmptyObject() {
        let expected: FieldType = .list(.unnamedObject([]))
        let type = try! FieldType(json: [
            "type": "list",
            "content": "object"
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testObjectWithSingleTextField() {
        let expected: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        let type = try! FieldType(json: [
            "type": "object",
            "properties": [
                "text": "string"
            ]
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let expected: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        let type = try! FieldType(json: [
            "type": "object",
            "properties": [
                "texts": [
                    "type": "list",
                    "content": "string"
                ]
            ]
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testObjectWithTwoSimpleFields() {
        let expected: FieldType = .unnamedObject([
            .init(name: "number", type: .number(.double)),
            .init(name: "texts", type: .list(.text))
        ])
        let type = try! FieldType(json: [
            "type": "object",
            "properties": [
                "number": "double",
                "texts": [
                    "type": "list",
                    "content": "string"
                ]
            ]
        ])
        XCTAssertEqual(type, expected)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let expected: FieldType = .unnamedObject([
            .init(name: "subObject", type: .unnamedObject([]))
        ])
        let type = try! FieldType(json: [
            "type": "object",
            "properties": [
                "subObject": "object"
            ]
        ])
        XCTAssertEqual(type, expected)
    }

    func testEnumWithOneCase() {
        let expected: FieldType = .unnamedEnum([.text])
        let type = try! FieldType(json: [
            "type": "any",
            "of": [
                "string"
            ]
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testEnumWithTwoCases() {
        let expected: FieldType = .unnamedEnum([.text, .number(.int)])
        let type = try! FieldType(json: [
            "type": "any",
            "of": [
                "int",
                "string"
            ]
        ])
        XCTAssertEqual(type, expected)
    }

    func testEnumWithOneSubDeclarationCase() {
        let expected: FieldType = .unnamedEnum([.unnamedObject([])])
        let type = try! FieldType(json: [
            "type": "any",
            "of": [
                "object"
            ]
        ])
        XCTAssertEqual(type, expected)
    }
    
    func testInvalidType() {
        do {
            let _ = try FieldType(json: "invalid")
            XCTFail("Expected error")
        } catch let FieldType.JSONConvertionError.invalidType(type) {
            XCTAssertEqual("invalid", type)
        } catch {
            XCTFail("Wrong error")
        }
    }
    
    func testUnexpectedJSON() {
        do {
            let _ = try FieldType(json: 10)
            XCTFail("Expected error")
        } catch let FieldType.JSONConvertionError.unexpectedPropertyType(json) {
            XCTAssertEqual(10, json)
        } catch {
            XCTFail("Wrong error")
        }
    }
    
    func testMissingType() {
        do {
            let _ = try FieldType(json: [:])
            XCTFail("Expected error")
        } catch let FieldType.JSONConvertionError.missingParameter(parameter) {
            XCTAssertEqual("type", parameter)
        } catch {
            XCTFail("Wrong error")
        }
    }
    
    func testReference() {
        let expected: FieldType = .object(name: "Test1", [
            .init(name: "number", type: .number(.double)),
            .init(name: "texts", type: .list(.text))
            ])
        let type = try! FieldType(json: [
            "definitions": [
                "Test1": [
                    "type": "object",
                    "properties": [
                        "number": "double",
                        "texts": [
                            "type": "list",
                            "content": "string"
                        ]
                    ]
                ]
            ],
            "$ref": "#/definitions/Test1"
        ])
        XCTAssertEqual(type, expected)
    }
    
}
