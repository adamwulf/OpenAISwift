//
//  File.swift
//  
//
//  Created by Adam Wulf on 2/5/23.
//

import Foundation

public extension CompletionsModel {
    func asDictionary() -> [String: String] {
        switch self {
        case .gpt3(let value):
            return ["gpt3": value.rawValue]
        case .codex(let value):
            return ["codex": value.rawValue]
        }
    }

    init?(with dictionary: [String: Any]) {
        if let value = dictionary["gpt3"] as? String,
           let gpt3 = CompletionsModel.GPT3(rawValue: value) {
            self = .gpt3(gpt3)
        } else if let value = dictionary["codex"] as? String,
                  let codex = CompletionsModel.Codex(rawValue: value) {
            self = .codex(codex)
        } else {
            return nil
        }
    }
}
