import XCTest
@testable import OpenAISwift

final class OpenAISwiftTests: XCTestCase {

    static let Timeout: TimeInterval = 15
    static let Token = "your key"

    func testConversation() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendCompletion(with: "Please respond with 'hi'.\n\nResponse:") { result in
            guard
                case .success(let foo) = result,
                let choice = foo.choices.first
            else {
                XCTFail()
                return
            }
            XCTAssert(choice.text.lowercased().contains("hi"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testConversationStops() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendCompletion(with: "Please respond with 'hi'.\n\nResponse:", stop: ["hi", "Hi"]) { result in
            guard
                case .success(let foo) = result,
                let choice = foo.choices.first
            else {
                XCTFail()
                return
            }
            XCTAssertFalse(choice.text.lowercased().contains("hi"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testConversationSuffix() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendCompletion(with: "When two people meet, they often say this two letter word:",
                              suffix: "which is a very common greeting.") { result in
            guard
                case .success(let foo) = result,
                let choice = foo.choices.first
            else {
                XCTFail()
                return
            }
            XCTAssert(choice.text.lowercased().contains("hi"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

}
