
import XCTest
import Foundation
@testable import ReverseJson

class FoundationTransformerTest: XCTestCase {
    
    static var allTests: [(String, (FoundationTransformerTest) -> () throws -> Void)] {
        return [
            ("testBoolFalse", testBoolFalse),
            ("testBoolTrue", testBoolTrue),
            ("testDouble", testDouble),
            ("testFloat", testFloat),
            ("testFloatNumber", testFloatNumber),
            ("testInt", testInt),
            ("testJsonBoolFalse", testJsonBoolFalse),
            ("testJsonBoolTrue", testJsonBoolTrue),
            ("testJsonDouble", testJsonDouble),
            ("testJsonEmptyArray", testJsonEmptyArray),
            ("testJsonEmptyObject", testJsonEmptyObject),
            ("testJsonInt", testJsonInt),
            ("testJsonIntArray", testJsonIntArray),
            ("testJsonIntExponential", testJsonIntExponential),
            ("testJsonIntNegativeExponential", testJsonIntNegativeExponential),
            ("testJsonNull", testJsonNull),
            ("testJsonNullArray", testJsonNullArray),
            ("testJsonObject", testJsonObject),
            ("testJsonOptionalStringArray", testJsonOptionalStringArray),
            ("testJsonString", testJsonString),
            ("testNil", testNil),
            ("testNonNilOptional", testNonNilOptional),
            ("testUInt", testUInt),
            ("testUnsupported", testUnsupported),
        ]
    }

    private func data(from jsonValue: String) throws -> Any {
        let data = "{\"value\":\(jsonValue)}".data(using: .utf8)!
        
        let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return jsonObj["value"]!
    }
    
    private let transformer = FoundationJSONTransformer()
    
    func testJsonIntNegativeExponential() throws {
        let jsonValue = "1E-3"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.number(.double(1E-3)))
    }
    
    func testJsonIntExponential() throws {
        let jsonValue = "1E3"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.number(.double(1E3)))
    }
    
    func testJsonBoolTrue() throws {
        let jsonValue = "true"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.bool(true))
    }
    
    func testJsonBoolFalse() throws {
        let jsonValue = "false"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.bool(false))
    }
    
    func testBoolTrue() throws {
        let json = try transformer.transform(true)
        XCTAssertEqual(json, JSON.bool(true))
    }
    
    func testBoolFalse() throws {
        let json = try transformer.transform(false)
        XCTAssertEqual(json, JSON.bool(false))
    }
    
    func testJsonInt() throws {
        let jsonValue = "1"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.number(.int(1)))
    }
    
    func testInt() throws {
        let json = try transformer.transform(1 as Int)
        XCTAssertEqual(json, JSON.number(.int(1)))
    }
    
    func testUInt() throws {
        let json = try transformer.transform(1 as UInt)
        XCTAssertEqual(json, JSON.number(.uint(1)))
    }
    
    func testJsonDouble() throws {
        let jsonValue = "1.2"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.number(.double(1.2)))
    }
    
    func testFloat() throws {
        let json = try transformer.transform(1 as Float)
        XCTAssertEqual(json, JSON.number(.float(1)))
    }
    
    func testDouble() throws {
        let json = try transformer.transform(1 as Double)
        XCTAssertEqual(json, JSON.number(.double(1)))
    }
    
    func testFloatNumber() throws {
        let float: Float = 1
        let json = try transformer.transform(NSNumber(value: float))
        #if os(Linux)
        // On Linux objCType is not implemented in NSNumber so we can't infer number type
        XCTAssertEqual(json, JSON.number(.double(1)))
        #else
        XCTAssertEqual(json, JSON.number(.float(1)))
        #endif
    }
    
    func testJsonString() throws {
        let jsonValue = "\"Simple string\""
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.string("Simple string"))
    }
    
    func testJsonNull() throws {
        let jsonValue = "null"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.null)
    }
    
    func testNil() throws {
        let json = try transformer.transform(Optional<Any>.none)
        XCTAssertEqual(json, JSON.null)
    }
    
    func testNonNilOptional() throws {
        let json = try transformer.transform(Optional<Any>.some("string"))
        XCTAssertEqual(json, JSON.string("string"))
    }
    
    func testJsonEmptyObject() throws {
        let jsonValue = "{}"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.object([:]))
    }
    
    func testJsonEmptyArray() throws {
        let jsonValue = "[]"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.array([]))
    }
    
    func testJsonNullArray() throws {
        let jsonValue = "[null, null]"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.array([.null, .null]))
    }
    
    func testJsonObject() throws {
        let jsonValue = "{\"Test\": \"123\"}"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.object(["Test": .string("123")]))
    }
    
    func testJsonIntArray() throws {
        let jsonValue = "[1,2,3]"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.array([.number(.int(1)), .number(.int(2)), .number(.int(3))]))
    }
    
    func testJsonOptionalStringArray() throws {
        let jsonValue = "[\"Test\", \"123\", null]"
        let json = try transformer.transform(try data(from: jsonValue))
        XCTAssertEqual(json, JSON.array([.string("Test"), .string("123"), .null]))
    }
    
    func testUnsupported() throws {
        do {
            let _ = try transformer.transform(NSObject())
            XCTFail("Error should be thrown")
        } catch {
        }
    }
}
