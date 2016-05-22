import XCTest
@testable import ReverseJsontest

XCTMain([
    testCase(ModelParserTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])