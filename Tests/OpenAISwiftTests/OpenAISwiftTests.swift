import XCTest
@testable import OpenAISwift

final class OpenAISwiftTests: XCTestCase {

    static let Timeout: TimeInterval = 10
    static let Token = "your key"

    func testExample() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendCompletion(with: "hello!") { result in
            guard case .success = result else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }
}
