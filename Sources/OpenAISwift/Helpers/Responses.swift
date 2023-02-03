//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

protocol OpenAIResponse: Codable { }

public struct TextResponse: OpenAIResponse {
    public let object: String
    public let model: String?
    public let choices: [Choice]
    public let usage: Usage
}

public struct Choice: Codable {
    public let text: String
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
    let promptTokens: Int
    let completionTokens: Int?
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
