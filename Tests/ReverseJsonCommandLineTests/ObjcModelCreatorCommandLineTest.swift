
import XCTest
import ReverseJsonCore
import ReverseJsonObjc
@testable import ReverseJsonCommandLine

class ObjcModelCreatorCommandLineTest: XCTestCase {
    
    static var allTests: [(String, (ObjcModelCreatorCommandLineTest) -> () throws -> Void)] {
        return [
            ("testAtomicFieldsFlag", testAtomicFieldsFlag),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testPrefixOption", testPrefixOption),
        ]
    }
    
    func testAtomicFieldsFlag() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-a"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--atomic"])
        XCTAssertEqual(modelCreator1.atomic, true)
        XCTAssertEqual(modelCreator2.atomic, true)
    }
    
    func testMutableFieldsFlag() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-m"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--mutable"])
        XCTAssertEqual(modelCreator1.readonly, false)
        XCTAssertEqual(modelCreator2.readonly, false)
    }
    
    
    func testPrefixOption() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-p", "ABC"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--prefix", "ABC"])
        XCTAssertEqual(modelCreator1.typePrefix, "ABC")
        XCTAssertEqual(modelCreator2.typePrefix, "ABC")
    }
    
}
