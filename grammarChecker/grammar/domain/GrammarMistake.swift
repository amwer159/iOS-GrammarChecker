//
//  Mistake.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation

struct GrammarMistake {
    let mistake: String
    let correction: String
    let errorInstance: Int
    let count: Int
}

extension GrammarMistake {
    func toWord(range: NSRange) -> GrammarWord {
        return GrammarWord(
            mistake: self.mistake,
            correction: self.correction,
            errorInstance: self.errorInstance,
            range: range
        )
    }
}
