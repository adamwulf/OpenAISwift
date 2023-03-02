//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

class ChatCompletionParams: Encodable {
    var messages: [OpenAIChatMessage]
    var model: String
    var maxTokens: Int
    var temperature: Float
    var stop: [String]?
    var user: String?

    init(messages: [OpenAIChatMessage], model: String, maxTokens: Int, temperature: Float, stop: [String]?, user: String?) {
        self.messages = messages
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.stop = stop
        self.user = user
    }

    enum CodingKeys: String, CodingKey {
        case messages
        case model
        case maxTokens = "max_tokens"
        case temperature
        case stop
        case user
    }
}

class CompletionParams: Encodable {
    var prompt: String
    var suffix: String?
    var model: String
    var maxTokens: Int
    var temperature: Float
    var stop: [String]?
    var user: String?

    init(prompt: String, suffix: String?, model: String, maxTokens: Int, temperature: Float, stop: [String]?, user: String?) {
        self.prompt = prompt
        self.suffix = suffix
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.stop = stop
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case suffix
        case model
        case maxTokens = "max_tokens"
        case temperature
        case stop
        case user
    }
}

class EditParams: Encodable {
    var instruction: String
    var model: String
    var input: String
    var temperature: Float

    init(instruction: String, input: String, model: String, temperature: Float) {
        self.instruction = instruction
        self.input = input
        self.model = model
        self.temperature = temperature
    }

    enum CodingKeys: String, CodingKey {
        case instruction
        case model
        case input
        case temperature
    }
}

class EmbeddingParams: Encodable {
    var input: String
    var model: String

    init(input: String, model: String) {
        self.input = input
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case input
        case model
    }
}

class ImageParams: Encodable {
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
