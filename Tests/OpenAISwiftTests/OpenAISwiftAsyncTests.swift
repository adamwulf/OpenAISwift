//
//  OpenAISwiftAsyncTests.swift
//  
//
//  Created by Adam Wulf on 3/11/23.
//

import XCTest
@testable import OpenAISwift

@MainActor final class OpenAISwiftAsyncTests: XCTestCase {

    static let Timeout: TimeInterval = 20

    /// In Xcode, Edit Scheme -> Run -> Arguments Tab -> Add Environment Variable -> Add your OpenAI API token with a var named "OpenAIToken"
    static let Token = ProcessInfo.processInfo.environment["OpenAIToken"]!

    func testConversation() async throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let result = try await openAI.sendCompletion(with: "Please respond with 'hi'.\n\nResponse:")

        guard let choice = result.choices.first else {
            XCTFail("\(result)")
            return
        }
        XCTAssert(choice.text.lowercased().contains("hi"))
    }

    func testChatConversation() async throws {
        let openAI = OpenAISwift(authToken: Self.Token)
        let result = try await openAI.sendCompletion(with: [OpenAIChatMessage(role: .user, content: "Please respond with 'hi'.\n\nResponse:")])

        guard let choice = result.choices.first else {
            XCTFail("\(result)")
            return
        }
        XCTAssert(choice.message.content.lowercased().contains("hi"))
    }

}
