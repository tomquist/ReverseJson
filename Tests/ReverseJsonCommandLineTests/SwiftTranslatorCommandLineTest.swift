
import XCTest
import ReverseJsonCore
import ReverseJsonSwift
@testable import ReverseJsonCommandLine

class SwiftTranslatorCommandLineTest: XCTestCase {
    
    static var allTests: [(String, (SwiftTranslatorCommandLineTest) -> () throws -> Void)] {
        return [
            ("testClassFlag", testClassFlag),
            ("testContiguousArrayFlag", testContiguousArrayFlag),
            ("testMutableFieldsFlag", testMutableFieldsFlag),
            ("testPublicFieldsFlag", testPublicFieldsFlag),
            ("testPublicTypeFlagWithObject", testPublicTypeFlagWithObject),
        ]
    }
    
    func testPublicTypeFlagWithObject() {
        let translator1 = SwiftTranslator(args: ["-pt"])
        let translator2 = SwiftTranslator(args: ["--publictypes"])
        let translator3 = SwiftTranslator(args: [])
        XCTAssertEqual(translator1.typeVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator2.typeVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator3.typeVisibility, Visibility.internalVisibility)
    }
    
    func testClassFlag() {
        let translator1 = SwiftTranslator(args: ["-c"])
        let translator2 = SwiftTranslator(args: ["--class"])
        let translator3 = SwiftTranslator(args: [])
        XCTAssertEqual(translator1.objectType, ObjectType.classType)
        XCTAssertEqual(translator2.objectType, ObjectType.classType)
        XCTAssertEqual(translator3.objectType, ObjectType.structType)
    }
    
    func testPublicFieldsFlag() {
        let translator1 = SwiftTranslator(args: ["-pf"])
        let translator2 = SwiftTranslator(args: ["--publicfields"])
        let translator3 = SwiftTranslator(args: [])
        XCTAssertEqual(translator1.fieldVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator2.fieldVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator3.fieldVisibility, Visibility.internalVisibility)
    }
    
    func testMutableFieldsFlag() {
        let translator1 = SwiftTranslator(args: ["-m"])
        let translator2 = SwiftTranslator(args: ["--mutable"])
        let translator3 = SwiftTranslator(args: [])
        XCTAssertEqual(translator1.mutableFields, true)
        XCTAssertEqual(translator2.mutableFields, true)
        XCTAssertEqual(translator3.mutableFields, false)
    }
    
    func testContiguousArrayFlag() {
        let translator1 = SwiftTranslator(args: ["-ca"])
        let translator2 = SwiftTranslator(args: ["--contiguousarray"])
        let translator3 = SwiftTranslator(args: [])
        XCTAssertEqual(translator1.listType, ListType.contiguousArray)
        XCTAssertEqual(translator2.listType, ListType.contiguousArray)
        XCTAssertEqual(translator3.listType, ListType.array)
    }
    
}
