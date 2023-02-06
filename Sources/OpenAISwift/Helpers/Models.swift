//
//  OpenAIModelType.swift
//  
//
//  Created by Yash Shah on 06/12/2022.
//

import Foundation

protocol OpenAIModel {
    var modelName: String { get }
    var maxTokens: Int { get }
}

/// The type of model used to generate the output
public enum CompletionsModel: OpenAIModel {
    /// ``GPT3`` Family of Models
    case gpt3(GPT3)
    
    /// ``Codex`` Family of Models
    case codex(Codex)

    public var modelName: String {
        switch self {
        case .gpt3(let model): return model.rawValue
        case .codex(let model): return model.rawValue
        }
    }

    public var maxTokens: Int {
        switch self {
        case .gpt3(let model): return model.maxTokens
        case .codex(let model): return model.maxTokens
        }
    }
    
    /// A set of models that can understand and generate natural language
    ///
    /// [GPT-3 Models OpenAI API Docs](https://beta.openai.com/docs/models/gpt-3)
    public enum GPT3: String, Codable {
        
        /// Most capable GPT-3 model. Can do any task the other models can do, often with higher quality, longer output and better instruction-following. Also supports inserting completions within text.
        ///
        /// > Model Name: text-davinci-003
        case davinci = "text-davinci-003"
        
        /// Very capable, but faster and lower cost than GPT3 ``davinci``.
        ///
        /// > Model Name: text-curie-001
        case curie = "text-curie-001"
        
        /// Capable of straightforward tasks, very fast, and lower cost.
        ///
        /// > Model Name: text-babbage-001
        case babbage = "text-babbage-001"
        
        /// Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost.
        ///
        /// > Model Name: text-ada-001
        case ada = "text-ada-001"

        public var maxTokens: Int {
            switch self {
            case .davinci: return 4000
            case .curie: return 2048
            case .babbage: return 2048
            case .ada: return 2048
            }
        }
    }
    
    /// A set of models that can understand and generate code, including translating natural language to code
    ///
    /// [Codex Models OpenAI API Docs](https://beta.openai.com/docs/models/codex)
    ///
    ///  >  Limited Beta
    public enum Codex: String, Codable {
        /// Most capable Codex model. Particularly good at translating natural language to code. In addition to completing code, also supports inserting completions within code.
        ///
        /// > Model Name: code-davinci-002
        case davinci = "code-davinci-002"
        
        /// Almost as capable as ``davinci`` Codex, but slightly faster. This speed advantage may make it preferable for real-time applications.
        ///
        /// > Model Name: code-cushman-001
        case cushman = "code-cushman-001"

        public var maxTokens: Int {
            switch self {
            case .davinci: return 8000
            case .cushman: return 2048
            }
        }
    }
}

extension CompletionsModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case gpt3
        case codex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(GPT3.self, forKey: .gpt3) {
            self = .gpt3(value)
        } else if let value = try? container.decode(Codex.self, forKey: .codex) {
            self = .codex(value)
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported CompletionsModel type")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gpt3(let value):
            try container.encode(value, forKey: .gpt3)
        case .codex(let value):
            try container.encode(value, forKey: .codex)
        }
    }
}

extension CompletionsModel: Equatable {
    public static func == (lhs: CompletionsModel, rhs: CompletionsModel) -> Bool {
        switch (lhs, rhs) {
        case (.gpt3(let lhsValue), .gpt3(let rhsValue)):
            return lhsValue == rhsValue
        case (.codex(let lhsValue), .codex(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

/// A set of models that are feature specific.
///
///  For example using the Edits endpoint requires a specific data model
///
///  You can read the [API Docs](https://beta.openai.com/docs/guides/completion/editing-text)
public enum EditsModel: String, Codable, Equatable, OpenAIModel {

    /// > Model Name: text-davinci-edit-001
    case davinciText = "text-davinci-edit-001"

    /// > Model Name: code-davinci-edit-001
    case davinciCode = "code-davinci-edit-001"

    public var modelName: String {
        return rawValue
    }

    public var maxTokens: Int {
        switch self {
        case .davinciText: return 3000
        case .davinciCode: return 3000
        }
    }
}

public enum EmbeddingModel: String, Codable, Equatable, OpenAIModel {
    /// > Model Name: text-embedding-ada-002
    case adaV2 = "text-embedding-ada-002"
    /// > Model Name: text-embedding-ada-001
    case adaV1 = "text-embedding-ada-001"

    public var modelName: String {
        return rawValue
    }

    public var maxTokens: Int {
        switch self {
        case .adaV1: return 2046
        case .adaV2: return 8191
        }
    }
}
