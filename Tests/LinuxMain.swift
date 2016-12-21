import XCTest
@testable import ReverseJsonCommandLineTests
@testable import ReverseJsonCoreTests
@testable import ReverseJsonObjcTests
@testable import ReverseJsonSwiftTests
@testable import ReverseJsonModelExportTests

XCTMain([
    testCase(ModelGeneratorCommandLineTest.allTests),
    testCase(ObjcModelCreatorCommandLineTest.allTests),
    testCase(ReverseJsonTest.allTests),
    testCase(SwiftTranslatorCommandLineTest.allTests),
    testCase(ModelGeneratorTest.allTests),
    testCase(ObjcModelTranslatorTest.allTests),
    testCase(SwiftTranslatorTest.allTests),
    testCase(JsonToModelTest.allTests),
    testCase(ModelExportTranslatorTest.allTests),
    testCase(ModelToJsonTest.allTests),
])
