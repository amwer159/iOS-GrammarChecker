//
//  GrammarResponse.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation

struct GrammarMistakeResponse: Codable {
    let mistake: String
    let correction: String
    let errorInstance: Int
    let count: Int
}

extension GrammarMistakeResponse {
    func toMistake() -> GrammarMistake {
        return GrammarMistake(
            mistake: self.mistake,
            correction: self.correction,
            errorInstance: self.errorInstance,
            count: self.count
        )
    }
}
