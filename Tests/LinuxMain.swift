import XCTest
@testable import ReverseJsontest

XCTMain([
    ModelParserTest(),
    ObjcModelTranslatorTest(),
    SwiftTranslatorTest(),
])