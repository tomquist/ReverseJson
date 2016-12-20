
import XCTest
import ReverseJsonCore
import CoreJSON
import CoreJSONLiterals
@testable import ReverseJsonModelExport

class ModelExportTranslatorTest: XCTestCase {
    
    func testSuccessfullSchemaCheck() {
        let json: JSON = [
            "type": "text",
            "$schema": .string(ModelExportTranslator.schemaIdentifier)
        ]
        XCTAssertTrue(ModelExportTranslator.isSchema(json))
    }
    
    func testFailedSchemaCheck1() {
        let json: JSON = [
            "some": "other",
            "json": 123
        ]
        XCTAssertFalse(ModelExportTranslator.isSchema(json))
    }
    
    func testFailedSchemaCheck2() {
        let json: JSON = 123
        XCTAssertFalse(ModelExportTranslator.isSchema(json))
    }
    
    func testPrettyTranslation() {
        var translator = ModelExportTranslator()
        translator.isPrettyPrinted = true
        let result = translator.translate(.text, name: "Test")
        let expected = [TranslatorOutput(name: "Test-model.json", content: "{\n  \"type\" : \"string\",\n  \"$schema\" : \"https:\\/\\/github.com\\/tomquist\\/ReverseJson\\/tree\\/1.2.0\"\n}")]
        XCTAssertEqual(result, expected)
    }

    func testNonPrettyTranslation() {
        var translator = ModelExportTranslator()
        translator.isPrettyPrinted = false
        let result = translator.translate(.text, name: "Test")
        let expected = [TranslatorOutput(name: "Test-model.json", content: "{\"type\":\"string\",\"$schema\":\"https:\\/\\/github.com\\/tomquist\\/ReverseJson\\/tree\\/1.2.0\"}")]
        XCTAssertEqual(result, expected)
    }

}

#if os(Linux)
extension ModelExportTranslatorTest {
    static var allTests: [(String, (ModelExportTranslatorTest) -> () throws -> Void)] {
        return [
            ("testSuccessfullSchemaCheck", testSuccessfullSchemaCheck),
            ("testFailedSchemaCheck1", testFailedSchemaCheck1),
            ("testFailedSchemaCheck2", testFailedSchemaCheck2),
            ("testPrettyTranslation", testPrettyTranslation),
            ("testNonPrettyTranslation", testNonPrettyTranslation),
        ]
    }
}
#endif
