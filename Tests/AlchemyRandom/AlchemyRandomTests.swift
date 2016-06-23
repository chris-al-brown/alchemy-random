import XCTest
@testable import AlchemyRandom

class AlchemyRandomTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(AlchemyRandom().text, "Hello, World!")
    }


    static var allTests : [(String, (AlchemyRandomTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
