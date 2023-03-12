import XCTest
@testable import OpenAISwift

final class OpenAISwiftTests: XCTestCase {

    static let Timeout: TimeInterval = 20

    /// In Xcode, Edit Scheme -> Run -> Arguments Tab -> Add Environment Variable -> Add your OpenAI API token with a var named "OpenAIToken"
    static let Token = ProcessInfo.processInfo.environment["OpenAIToken"]!

    func testRealtimeConversation() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")
        let prompt = "Please tell me a story about a friendly duck and a friendly bear"

        openAI.realtimeCompletion(with: [OpenAIChatMessage(role: .user, content: prompt)],
                                  maxTokens: 1000) { update, err in
            print("\(String(describing: update))")
        } completionHandler: { result in
            guard
                case .success(let foo) = result,
                let choice = foo.choices.first
            else {
                XCTFail("\(result)")
                return
            }
            XCTAssert(choice.message.content.lowercased().contains("duck"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testConversation() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendCompletion(with: "Please respond with 'hi'.\n\nResponse:") { result in
            guard
                case .success(let foo) = result,
                let choice = foo.choices.first
            else {
                XCTFail("\(result)")
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
                XCTFail("\(result)")
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
                XCTFail("\(result)")
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
                XCTFail("\(result)")
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
                XCTFail("\(result)")
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

        openAI.sendEdits(with: "Only fix the spelling mistake.", input: "My nam is Adam.", temperature: 0) { result in
            guard
                case .success(let response) = result,
                let choice = response.choices.first
            else {
                XCTFail("\(result)")
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

        openAI.sendEdits(with: "Fix the spelling mistake.", input: "var recieveCode = 1234;", model: .davinciCode, temperature: 0) { result in
            guard
                case .success(let response) = result,
                let choice = response.choices.first
            else {
                XCTFail("\(result)")
                return
            }

            XCTAssertEqual(choice.text.trimmingCharacters(in: .whitespacesAndNewlines), "var receiveCode = 1234;")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testEmbedding() throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let expectation = self.expectation(description: "expectation")

        openAI.sendEmbedding(for: "Swift is a programming language") { result in
            guard
                case .success(let response) = result,
                let data = response.data.first
            else {
                XCTFail("\(result)")
                return
            }
            XCTAssertGreaterThan(data.embedding.count, 1000)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Self.Timeout)
    }

    func testEncodeModel() throws {
        let model: CompletionsModel = .gpt3(.davinci)
        let jsonData = try JSONEncoder().encode(model)
        let decoded = try JSONDecoder().decode(CompletionsModel.self, from: jsonData)
        XCTAssertEqual(model, decoded)
    }

    func testEncodeModel2() throws {
        let model: CompletionsModel = .gpt3(.davinci)
        let jsonDictionary = model.asDictionary()
        let decoded = CompletionsModel(with: jsonDictionary)
        XCTAssertEqual(model, decoded)
    }
}
