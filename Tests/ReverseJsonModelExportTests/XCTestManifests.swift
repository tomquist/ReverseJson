#if !canImport(ObjectiveC)
import XCTest

extension JsonToModelTest {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JsonToModelTest = [
        ("testEmptyObject", testEmptyObject),
        ("testEnumWithOneCase", testEnumWithOneCase),
        ("testEnumWithOneSubDeclarationCase", testEnumWithOneSubDeclarationCase),
        ("testEnumWithTwoCases", testEnumWithTwoCases),
        ("testInvalidType", testInvalidType),
        ("testListOfEmptyObject", testListOfEmptyObject),
        ("testListOfTextList", testListOfTextList),
        ("testListOfUnknown", testListOfUnknown),
        ("testListWithoutContent", testListWithoutContent),
        ("testMissingType", testMissingType),
        ("testNamedEmptyObject", testNamedEmptyObject),
        ("testNamedEmptyUnknown", testNamedEmptyUnknown),
        ("testObjectWithFieldContainingListOfText", testObjectWithFieldContainingListOfText),
        ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
        ("testObjectWithSingleTextField", testObjectWithSingleTextField),
        ("testObjectWithTwoSimpleFields", testObjectWithTwoSimpleFields),
        ("testOptionalInt", testOptionalInt),
        ("testOptionalText", testOptionalText),
        ("testOptionalUnknown", testOptionalUnknown),
        ("testReference", testReference),
        ("testSimpleBool", testSimpleBool),
        ("testSimpleDouble", testSimpleDouble),
        ("testSimpleFloat", testSimpleFloat),
        ("testSimpleInt", testSimpleInt),
        ("testSimpleString", testSimpleString),
        ("testTextList", testTextList),
        ("testUnexpectedJSON", testUnexpectedJSON),
        ("testUnknown", testUnknown),
    ]
}

extension ModelExportTranslatorTest {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ModelExportTranslatorTest = [
        ("testFailedSchemaCheck1", testFailedSchemaCheck1),
        ("testFailedSchemaCheck2", testFailedSchemaCheck2),
        ("testNonPrettyTranslation", testNonPrettyTranslation),
        ("testPrettyTranslation", testPrettyTranslation),
        ("testSuccessfullSchemaCheck", testSuccessfullSchemaCheck),
    ]
}

extension ModelToJsonTest {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ModelToJsonTest = [
        ("testEmptyEnum", testEmptyEnum),
        ("testEmptyObject", testEmptyObject),
        ("testEnumWithOneCase", testEnumWithOneCase),
        ("testEnumWithOneSubDeclarationCase", testEnumWithOneSubDeclarationCase),
        ("testEnumWithTwoCases", testEnumWithTwoCases),
        ("testListOfEmptyObject", testListOfEmptyObject),
        ("testListOfTextList", testListOfTextList),
        ("testListOfUnknown", testListOfUnknown),
        ("testNamedEmptyEnum", testNamedEmptyEnum),
        ("testNamedEmptyObject", testNamedEmptyObject),
        ("testObjectWithFieldContainingListOfText", testObjectWithFieldContainingListOfText),
        ("testObjectWithOneFieldWithSubDeclaration", testObjectWithOneFieldWithSubDeclaration),
        ("testObjectWithSingleTextField", testObjectWithSingleTextField),
        ("testObjectWithTwoSimpleFields", testObjectWithTwoSimpleFields),
        ("testOptionalText", testOptionalText),
        ("testOptionalUnknown", testOptionalUnknown),
        ("testSimpleBool", testSimpleBool),
        ("testSimpleDouble", testSimpleDouble),
        ("testSimpleFloat", testSimpleFloat),
        ("testSimpleInt", testSimpleInt),
        ("testSimpleString", testSimpleString),
        ("testTextList", testTextList),
        ("testUnknownType", testUnknownType),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JsonToModelTest.__allTests__JsonToModelTest),
        testCase(ModelExportTranslatorTest.__allTests__ModelExportTranslatorTest),
        testCase(ModelToJsonTest.__allTests__ModelToJsonTest),
    ]
}
#endif
