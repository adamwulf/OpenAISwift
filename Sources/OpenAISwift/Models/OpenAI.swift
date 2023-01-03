//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

public struct OpenAI: Codable {
    public let object: String
    public let model: String?
    public let choices: [Choice]
}

public struct Choice: Codable {
    public let text: String
}

public struct OpenAIImageResponse: Codable {
    public let data: [OpenAIImage]
}

public struct OpenAIImage: Codable {
    public let url: String?
    public let b64_json: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.b64_json = try container.decodeIfPresent(String.self, forKey: .b64_json)
    }
}
