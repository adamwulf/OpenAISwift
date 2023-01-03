//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

class Command: Encodable {
    var prompt: String
    var suffix: String?
    var model: String
    var maxTokens: Int
    var temperature: Float
    var user: String?

    init(prompt: String, suffix: String?, model: String, maxTokens: Int, temperature: Float, user: String?) {
        self.prompt = prompt
        self.suffix = suffix
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case suffix
        case model
        case maxTokens = "max_tokens"
        case temperature
        case user
    }
}


class ImageCommand: Encodable {
    var prompt: String
    var n: Int?
    var size: String?
    var responseFormat: String?
    var user: String?

    init(prompt: String, n: Int?, size: String?, responseFormat: String?, user: String?) {
        self.prompt = prompt
        self.n = n
        self.size = size
        self.responseFormat = responseFormat
        self.user = user
    }

    enum CodingKeys: String, CodingKey {
        case prompt
        case n
        case size
        case responseFormat = "response_format"
        case user
    }
}
