import XCTest
import Foundation
import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc
@testable import ReverseJsonCommandLine

struct DummyTranslator: ModelTranslator {
    let fileName: String
    
    func translate(_ type: FieldType, name: String) -> [TranslatorOutput] {
        return [TranslatorOutput(name: fileName, content: "\(name): \(type)")]
    }
}

class ReverseJsonTest: XCTestCase {
    
    private func resourcePath(_ name: String) -> String {
        return URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Inputs").appendingPathComponent(name).path
    }
    
    func testConsoleOutput() {
        let modelGenerator = ModelGenerator()
        let reverseJson = ReverseJson(json: "Test", modelName: "Name", modelGenerator: modelGenerator, translator: DummyTranslator(fileName: "fileName"), writeToConsole: true, outputDirectory: "")
        XCTAssertEqual(try? reverseJson.main(), "// fileName\nName: \(modelGenerator.decode(.string("Test")))")
    }
    
    func testExistingOutputButNotADir() {
        let fileName = "ReverseJsonTestExistingFile"
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let outUrl = tmpDir.appendingPathComponent(fileName, isDirectory: false)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true, attributes: nil)
        if FileManager.default.fileExists(atPath: outUrl.path, isDirectory: nil) {
            try? FileManager.default.removeItem(at: outUrl)
        }
        let _ = FileManager.default.createFile(atPath: outUrl.path, contents: nil, attributes: nil)
        defer {
            try? FileManager.default.removeItem(at: outUrl)
        }
        let modelGenerator = ModelGenerator()
        let reverseJson = ReverseJson(json: "Test", modelName: "Name", modelGenerator: modelGenerator, translator: DummyTranslator(fileName: fileName), writeToConsole: false, outputDirectory: outUrl.path)
        do {
            let _ = try reverseJson.main()
            XCTFail()
        } catch ReverseJsonError.outputPathIsNoDirectory(let dir) {
            XCTAssertEqual(dir, outUrl.path)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testNonExistingOutputDir() {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let outUrl = tmpDir.appendingPathComponent("ReverseJsonTestNonExistingDir", isDirectory: true)
        if FileManager.default.fileExists(atPath: outUrl.path, isDirectory: nil) {
            try? FileManager.default.removeItem(at: outUrl)
        }
        let modelGenerator = ModelGenerator()
        let reverseJson = ReverseJson(json: "Test", modelName: "Name", modelGenerator: modelGenerator, translator: DummyTranslator(fileName: "fileName"), writeToConsole: false, outputDirectory: outUrl.path)
        do {
            let _ = try reverseJson.main()
            XCTFail()
        } catch ReverseJsonError.outputDirectoryDoesNotExist(let dir) {
            XCTAssertEqual(dir, outUrl.path)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFileOutput() {
        let outUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        let fileName = "ReverseJsonTestDummyOutput"
        defer {
            let outFile = outUrl.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: outFile)
        }
        let modelGenerator = ModelGenerator()
        let reverseJson = ReverseJson(json: "Test", modelName: "Name", modelGenerator: modelGenerator, translator: DummyTranslator(fileName: fileName), writeToConsole: false, outputDirectory: outUrl.path)
        do {
            let _ = try reverseJson.main()
        } catch {
            XCTFail(error.localizedDescription)
        }
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
    
    func testVerbose() {
        do {
            let reverseJson0 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json")])
            let reverseJson1 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "-v"])
            let reverseJson2 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "--verbose"])
            XCTAssertFalse(reverseJson0.writeToConsole)
            XCTAssertTrue(reverseJson1.writeToConsole)
            XCTAssertTrue(reverseJson2.writeToConsole)
        } catch {
            XCTFail()
        }
    }
    
    func testOutDir() {
        do {
            let reverseJson0 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json")])
            let reverseJson1 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "-o", "bla"])
            let reverseJson2 = try ReverseJson(args: ["ReverseJson", "swift", "Test", resourcePath("valid.json"), "--out", "bla"])
            XCTAssertEqual("", reverseJson0.outputDirectory)
            XCTAssertEqual("bla", reverseJson1.outputDirectory)
            XCTAssertEqual("bla", reverseJson2.outputDirectory)
        } catch {
            XCTFail()
        }
    }
    
}

#if os(Linux)
extension ReverseJsonTest {
    
    static var allTests: [(String, (ReverseJsonTest) -> () throws -> Void)] {
        return [
            ("testConsoleOutput", testConsoleOutput),
            ("testNonExistingOutputDir", testNonExistingOutputDir),
            ("testExistingOutputButNotADir", testExistingOutputButNotADir),
            ("testFileOutput", testFileOutput),
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
            ("testVerbose", testVerbose),
            ("testOutDir", testOutDir)
        ]
    }
}
#endif
