//
//  File.swift
//  
//
//  Created by Adam Wulf on 2/2/23.
//

import Foundation

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
