//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

enum Endpoint {
    case completions
    case embeddings
    case edits
    case imageGenerations
}

extension Endpoint {
    var path: String {
        switch self {
        case .completions:
            return "/v1/completions"
        case .embeddings:
            return "/v1/embeddings"
        case .edits:
            return "/v1/edits"
        case .imageGenerations:
            return "/v1/images/generations"
        }
    }
    
    var method: String {
        switch self {
        case .completions, .embeddings, .edits, .imageGenerations:
            return "POST"
        }
    }
    
    func baseURL() -> String {
        switch self {
        case .completions, .embeddings, .edits, .imageGenerations:
            return "https://api.openai.com"
        }
    }
}
