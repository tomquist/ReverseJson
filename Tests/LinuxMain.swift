import XCTest
@testable import ReverseJsonCoreTests
@testable import ReverseJsonObjcTests
@testable import ReverseJsonSwiftTests
@testable import ReverseJsonFoundationTests

XCTMain([
    testCase(FoundationTransformerTest.allTests),
    testCase(ModelGeneratorTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
])
