
import XCTest
import ReverseJsonCore
@testable import ReverseJsonModelExport

class ModelToJsonTest: XCTestCase {
    
    func testSimpleString() {
        let type: FieldType = .text
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("string", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testSimpleInt() {
        let type: FieldType = .number(.int)
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("int", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testSimpleFloat() {
        let type: FieldType = .number(.float)
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("float", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testSimpleDouble() {
        let type: FieldType = .number(.double)
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("double", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testSimpleBool() {
        let type: FieldType = .number(.bool)
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("bool", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testEmptyObject() {
        let type: FieldType = .unnamedObject([])
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("object", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testNamedEmptyObject() {
        let type: FieldType = .object(name: "Object", [])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "object",
            "name": "Object"
        ], json)
    }
    
    func testEmptyEnum() {
        let type: FieldType = .unnamedEnum([])
        let json = type.toJSON(isRoot: false)
        XCTAssertEqual("any", json)
        let rootJson = type.toJSON(isRoot: true)
        XCTAssertEqual([
            "type": json,
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ], rootJson)
    }
    
    func testNamedEmptyEnum() {
        let type: FieldType = .enum(name: "Enum", [])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "any",
            "name": "Enum"
        ], json)
    }

    
    func testTextList() {
        let type: FieldType = .list(.text)
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "list",
            "content": "string"
        ], json)
    }
    
    func testListOfTextList() {
        let type: FieldType = .list(.list(.text))
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "list",
            "content": [
                "type": "list",
                "content": "string"
            ]
        ], json)
    }

    func testUnknownType() {
        let type: FieldType = .unnamedUnknown
        let json = type.toJSON()
        XCTAssertEqual("any", json)
    }
    
    func testOptionalUnknown() {
        let type: FieldType = .optional(.unnamedUnknown)
        let json = type.toJSON()
        XCTAssertEqual("any?", json)
    }
    
    func testListOfUnknown() {
        let type: FieldType = .list(.unnamedUnknown)
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "list",
            "content": "any"
        ], json)
    }
    
    func testOptionalText() {
        let type: FieldType = .optional(.text)
        let json = type.toJSON()
        XCTAssertEqual("string?", json)
    }
    
    func testListOfEmptyObject() {
        let type: FieldType = .list(.unnamedObject([]))
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "list",
            "content": "object"
        ], json)
    }
    
    func testObjectWithSingleTextField() {
        let type: FieldType = .unnamedObject([.init(name: "text", type: .text)])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "object",
            "properties": [
                "text": "string"
            ]
        ], json)
    }
    
    func testObjectWithFieldContainingListOfText() {
        let type: FieldType = .unnamedObject([.init(name: "texts", type: .list(.text))])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "object",
            "properties": [
                "texts": [
                    "type": "list",
                    "content": "string"
                ]
            ]
        ], json)
    }
    
    func testObjectWithTwoSimpleFields() {
        let type: FieldType = .unnamedObject([
            .init(name: "number", type: .number(.double)),
            .init(name: "texts", type: .list(.text))
        ])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "object",
            "properties": [
                "number": "double",
                "texts": [
                    "type": "list",
                    "content": "string"
                ]
            ]
        ], json)
    }

    func testObjectWithOneFieldWithSubDeclaration() {
        let type: FieldType = .unnamedObject([
            .init(name: "subObject", type: .unnamedObject([]))
        ])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "object",
            "properties": [
                "subObject": "object"
            ]
        ], json)
    }

    func testEnumWithOneCase() {
        let type: FieldType = .unnamedEnum([.text])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "any",
            "of": [
                "string"
            ]
        ], json)
    }
    
    func testEnumWithTwoCases() {
        let type: FieldType = .unnamedEnum([.text, .number(.int)])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "any",
            "of": [
                "int",
                "string"
            ]
        ], json)
    }

    func testEnumWithOneSubDeclarationCase() {
        let type: FieldType = .unnamedEnum([.unnamedObject([])])
        let json = type.toJSON()
        XCTAssertEqual([
            "type": "any",
            "of": [
                "object"
            ]
        ], json)
    }
    
}
