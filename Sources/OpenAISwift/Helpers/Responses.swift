//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

protocol OpenAIResponse: Codable { }

public struct ChatChoice: Codable {
    public struct Message: Codable {
        public let role: String
        public let content: String
    }
    public let message: Message
}

public struct ChatResponse: OpenAIResponse {
    public let object: String
    public let model: String?
    public let choices: [ChatChoice]
    public let usage: Usage
}

public struct RealtimeChatChoice: Codable {
    public struct Delta: Codable {
        public let role: String?
        public let content: String?
    }
    public let delta: Delta
}

public struct RealtimeChatUpdate: OpenAIResponse {
    public let object: String
    public let model: String?
    public let choices: [RealtimeChatChoice]
    public let created: Int
    public let id: String
}

public struct TextResponse: OpenAIResponse {
    public let object: String
    public let model: String?
    public let choices: [Choice]
    public let usage: Usage

    public init(object: String, model: String?, choices: [Choice], usage: Usage) {
        self.object = object
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}

public struct Choice: Codable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}

public struct EmbeddingResponse: OpenAIResponse {
    public let object: String
    public let data: [Embedding]
    public let model: String
    public let usage: Usage
}

public struct Embedding: Codable {
    public let object: String
    public let embedding: [Float]
    public let index: Int
}

public struct ImageResponse: OpenAIResponse {
    public let data: [Image]
}

public struct Image: Codable {
    public let url: String?
    public let b64_json: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.b64_json = try container.decodeIfPresent(String.self, forKey: .b64_json)
    }
}

public struct Usage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int?
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
