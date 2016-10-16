
import XCTest
import ReverseJsonCore
@testable import ReverseJsonCommandLine

class ModelGeneratorCommandLineTest: XCTestCase {
    
    static var allTests: [(String, (ModelGeneratorCommandLineTest) -> () throws -> Void)] {
        return [
            ("testAllFieldsOptionalFlag", testAllFieldsOptionalFlag),
        ]
    }
    
    func testAllFieldsOptionalFlag() {
        let generator1 = try! ModelGenerator(args: ["-n"])
        let generator2 = try! ModelGenerator(args: ["--nullable"])
        let generator3 = try! ModelGenerator(args: [])
        XCTAssertEqual(generator1.allFieldsOptional, true)
        XCTAssertEqual(generator2.allFieldsOptional, true)
        XCTAssertEqual(generator3.allFieldsOptional, false)
    }

}
