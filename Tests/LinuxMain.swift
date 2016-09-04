import XCTest
@testable import ReverseJsonTests

XCTMain([
    testCase(FoundationTransformerTest.allTests),
    testCase(ModelGeneratorTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])
