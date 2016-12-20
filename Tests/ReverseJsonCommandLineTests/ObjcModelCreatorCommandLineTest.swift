
import XCTest
import ReverseJsonCore
import ReverseJsonObjc
@testable import ReverseJsonCommandLine

class ObjcModelCreatorCommandLineTest: XCTestCase {
    
    func testAtomicFieldsFlag() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-a"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--atomic"])
        let modelCreator3 = try! ObjcModelCreator(args: [])
        XCTAssertEqual(modelCreator1.atomic, true)
        XCTAssertEqual(modelCreator2.atomic, true)
        XCTAssertEqual(modelCreator3.atomic, false)
    }
    
    func testMutableFieldsFlag() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-m"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--mutable"])
        let modelCreator3 = try! ObjcModelCreator(args: [])
        XCTAssertEqual(modelCreator1.readonly, false)
        XCTAssertEqual(modelCreator2.readonly, false)
        XCTAssertEqual(modelCreator3.readonly, true)
    }
    
    func testReverseMappingFlag() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-r"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--reversemapping"])
        let modelCreator3 = try! ObjcModelCreator(args: [])
        XCTAssertEqual(modelCreator1.createToJson, true)
        XCTAssertEqual(modelCreator2.createToJson, true)
        XCTAssertEqual(modelCreator3.createToJson, false)
    }
    
    func testPrefixOption() {
        let modelCreator1 = try! ObjcModelCreator(args: ["-p", "ABC"])
        let modelCreator2 = try! ObjcModelCreator(args: ["--prefix", "ABC"])
        let modelCreator3 = try! ObjcModelCreator(args: [])
        XCTAssertEqual(modelCreator1.typePrefix, "ABC")
        XCTAssertEqual(modelCreator2.typePrefix, "ABC")
        XCTAssertEqual(modelCreator3.typePrefix, "")
    }
    
}


#if os(Linux)
extension ObjcModelCreatorCommandLineTest {
    static var allTests: [(String, (ObjcModelCreatorCommandLineTest) -> () throws -> Void)] {
        return [
            ("testAtomicFieldsFlag", testAtomicFieldsFlag),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testPrefixOption", testPrefixOption),
        ]
    }
}
#endif
