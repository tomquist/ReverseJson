#if !os(Linux)
    public protocol XCTestCaseProvider {
        var allTests: [(String, () throws -> Void)] { get }
    }
#endif