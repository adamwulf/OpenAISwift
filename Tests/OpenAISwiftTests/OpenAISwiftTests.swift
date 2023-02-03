import XCTest
@testable import OpenAISwift

final class OpenAISwiftTests: XCTestCase {

    static let Timeout: TimeInterval = 20
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

    func testImageURLGeneration() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendImageGeneration(with: "a cartoon bear", size: .x256) { result in
            guard
                case .success(let response) = result,
                let image = response.data.first
            else {
                XCTFail()
                return
            }
            XCTAssertNotNil(image.url)
            XCTAssertNil(image.b64_json)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testImageB64Generation() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendImageGeneration(with: "a cartoon bear", size: .x256, responseFormat: .b64JSON) { result in
            guard
                case .success(let response) = result,
                let image = response.data.first
            else {
                XCTFail()
                return
            }
            XCTAssertNotNil(image.b64_json)
            XCTAssertNil(image.url)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testEditText() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendEdits(with: "Fix the spelling mistake.", input: "My nam is Adam.") { result in
            guard
                case .success(let response) = result,
                let choice = response.choices.first
            else {
                XCTFail()
                return
            }

            XCTAssertEqual(choice.text.trimmingCharacters(in: .whitespacesAndNewlines), "My name is Adam.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testEditCode() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendEdits(with: "Fix the spelling mistake.", model: .feature(.davinciCode), input: "var recieveCode = 1234;") { result in
            guard
                case .success(let response) = result,
                let choice = response.choices.first
            else {
                XCTFail()
                return
            }

            XCTAssertEqual(choice.text.trimmingCharacters(in: .whitespacesAndNewlines), "var receiveCode = 1234;")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

}
