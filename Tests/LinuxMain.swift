import XCTest

import ReverseJsonCommandLineTests
import ReverseJsonCoreTests
import ReverseJsonModelExportTests
import ReverseJsonObjcTests
import ReverseJsonSwiftTests

var tests = [XCTestCaseEntry]()
tests += ReverseJsonCommandLineTests.__allTests()
tests += ReverseJsonCoreTests.__allTests()
tests += ReverseJsonModelExportTests.__allTests()
tests += ReverseJsonObjcTests.__allTests()
tests += ReverseJsonSwiftTests.__allTests()

XCTMain(tests)
