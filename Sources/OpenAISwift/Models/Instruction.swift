//
//  Created by Adam Rush - OpenAISwift
//

import Foundation

class Instruction: Encodable {
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
