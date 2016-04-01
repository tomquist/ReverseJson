import XCTest
@testable import ReverseJsontest

XCTMain([
    ModelParserTests(),
    ObjcModelTranslatorTest(),
    SwiftTranslatorTest(),
])