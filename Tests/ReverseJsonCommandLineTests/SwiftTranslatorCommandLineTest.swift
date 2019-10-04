
import XCTest
import ReverseJsonCore
import ReverseJsonSwift
@testable import ReverseJsonCommandLine

class SwiftTranslatorCommandLineTest: XCTestCase {
    
    func testPublicTypeFlagWithObject() {
        let translator1 = try! SwiftTranslator(args: ["-pt"])
        let translator2 = try! SwiftTranslator(args: ["--publictypes"])
        let translator3 = try! SwiftTranslator(args: [])
        XCTAssertEqual(translator1.typeVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator2.typeVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator3.typeVisibility, Visibility.internalVisibility)
    }
    
    func testClassFlag() {
        let translator1 = try! SwiftTranslator(args: ["-c"])
        let translator2 = try! SwiftTranslator(args: ["--class"])
        let translator3 = try! SwiftTranslator(args: [])
        XCTAssertEqual(translator1.objectType, ObjectType.classType)
        XCTAssertEqual(translator2.objectType, ObjectType.classType)
        XCTAssertEqual(translator3.objectType, ObjectType.structType)
    }
    
    func testPublicFieldsFlag() {
        let translator1 = try! SwiftTranslator(args: ["-pf"])
        let translator2 = try! SwiftTranslator(args: ["--publicfields"])
        let translator3 = try! SwiftTranslator(args: [])
        XCTAssertEqual(translator1.fieldVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator2.fieldVisibility, Visibility.publicVisibility)
        XCTAssertEqual(translator3.fieldVisibility, Visibility.internalVisibility)
    }
    
    func testMutableFieldsFlag() {
        let translator1 = try! SwiftTranslator(args: ["-m"])
        let translator2 = try! SwiftTranslator(args: ["--mutable"])
        let translator3 = try! SwiftTranslator(args: [])
        XCTAssertEqual(translator1.mutableFields, true)
        XCTAssertEqual(translator2.mutableFields, true)
        XCTAssertEqual(translator3.mutableFields, false)
    }
    
    func testContiguousArrayFlag() {
        let translator1 = try! SwiftTranslator(args: ["-ca"])
        let translator2 = try! SwiftTranslator(args: ["--contiguousarray"])
        let translator3 = try! SwiftTranslator(args: [])
        XCTAssertEqual(translator1.listType, ListType.contiguousArray)
        XCTAssertEqual(translator2.listType, ListType.contiguousArray)
        XCTAssertEqual(translator3.listType, ListType.array)
    }
    
}
