import XCTest
@testable import ReverseJsonTests

XCTMain([
    testCase(ModelParserTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])