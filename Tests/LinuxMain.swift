import XCTest
@testable import ReverseJsonTestSuite

XCTMain([
    testCase(ModelParserTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])