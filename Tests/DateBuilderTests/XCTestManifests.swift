#if !os(watchOS)
import XCTest
#endif

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DateBuilderTests.allTests),
    ]
}
#endif
