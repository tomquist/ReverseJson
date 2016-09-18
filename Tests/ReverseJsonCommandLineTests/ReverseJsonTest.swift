import XCTest
import Foundation
import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc
@testable import ReverseJsonCommandLine

struct DummyTranslator: ModelTranslator {
    func translate(_ type: FieldType, name: String) -> String {
        return "\(name): \(type)"
    }
}

class ReverseJsonTest: XCTestCase {
    
    static var allTests: [(String, (ReverseJsonTest) -> () throws -> Void)] {
        return [
            ("testDefault", testDefault),
            ("testHasUsage", testHasUsage),
            ("testNoArguments", testNoArguments),
            ("testWrongArgumentCount", testWrongArgumentCount),
            ("testUnknownLanguage", testUnknownLanguage),
            ("testNonExistingFile", testNonExistingFile),
            ("testInvalidJson", testInvalidJson),
            ("testSwift", testSwift),
            ("testObjc", testObjc),
            ("testModelName", testModelName),
            ("testPassArgumentsToTranslator", testPassArgumentsToTranslator),
            ("testPassArgumentsToModelGenerator", testPassArgumentsToModelGenerator),
            ("testParsedJson", testParsedJson),
        ]
    }
    
    private func resourcePath(_ name: String) -> String {
        return URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Inputs").appendingPathComponent(name).path
    }
    
    func testDefault() {
        let modelGenerator = ModelGenerator()
        let reverseJson = ReverseJson(json: "Test", modelName: "Name", modelGenerator: modelGenerator, translator: DummyTranslator())
        XCTAssertEqual(try? reverseJson.main(), "Name: \(modelGenerator.decode(.string("Test")))")
    }
    
    func testHasUsage() {
        let usage = ReverseJson.usage(command: "__IGNORE__/__XYZ__")
        XCTAssertFalse(usage.isEmpty)
        XCTAssertTrue(usage.contains("__XYZ__"))
        XCTAssertFalse(usage.contains("__IGNORE__"))
    }
    
    func testNoArguments() {
        do {
            let _ = try ReverseJson(args: [])
            XCTFail()
        } catch ReverseJsonError.wrongArgumentCount {
            return
        } catch {
            XCTFail()
        }
    }
    
    func testWrongArgumentCount() {
        do {
            let _ = try ReverseJson(args: ["1", "2", "3"])
            XCTFail()
        } catch ReverseJsonError.wrongArgumentCount {
            return
        } catch {
            XCTFail()
        }
    }
    
    func testUnknownLanguage() {
        do {
            let _ = try ReverseJson(args: ["ReverseJson", "python", "Test", resourcePath("valid.json")])
            XCTFail()
        } catch ReverseJsonError.unsupportedLanguage("python") {
            return
        } catch {
            XCTFail()
        }
    }
    
    func testNonExistingFile() {
        do {
            let _ = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("nonExisting.json")])
            XCTFail()
        } catch ReverseJsonError.unableToRead(file: resourcePath("nonExisting.json"), _) {
            return
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidJson() {
        do {
            let _ = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("invalid.json")])
            XCTFail()
        } catch ReverseJsonError.unableToParseFile {
            return
        } catch {
            XCTFail()
        }
    }
    
    func testSwift() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json")])
            XCTAssertTrue(reverseJson.translator is SwiftTranslator)
        } catch {
            XCTFail()
        }
    }
    
    func testObjc() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "objc", "Test", resourcePath("valid.json")])
            XCTAssertTrue(reverseJson.translator is ObjcModelCreator)
        } catch {
            XCTFail()
        }
    }
    
    func testPassArgumentsToTranslator() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "--mutable"])
            guard let translator = reverseJson.translator as? SwiftTranslator else {
                XCTFail()
                return
            }
            XCTAssertTrue(translator.mutableFields)
        } catch {
            XCTFail()
        }
    }
    
    func testPassArgumentsToModelGenerator() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "--nullable"])
            XCTAssertTrue(reverseJson.modelGenerator.allFieldsOptional)
        } catch {
            XCTFail()
        }
    }
    
    func testModelName() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json")])
            XCTAssertEqual(reverseJson.modelName, "Test")
        } catch {
            XCTFail()
        }
    }
    
    func testParsedJson() {
        do {
            let reverseJson = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json")])
            let dict = reverseJson.json as? [String: Any]
            XCTAssertNotNil(dict)
            XCTAssertEqual(dict?["height"] as? Int, 10)
        } catch {
            XCTFail()
        }
    }
    
}
