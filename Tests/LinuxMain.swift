import XCTest
@testable import ReverseJsonLibTests
@testable import ReverseJsonFoundationTests

XCTMain([
    testCase(FoundationTransformerTest.allTests),
    testCase(ModelGeneratorTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])
