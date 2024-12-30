//
//  GrammarMistakeParser.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation

internal class GrammarMistakeParser {
    
    func parse(response: String) -> [GrammarMistakeResponse] {
        if let data = response.data(using: .utf16) {
            let decoder = JSONDecoder()
            do {
                let mistakes = try decoder.decode([GrammarMistakeResponse].self, from: data)
                // Filter out mistakes where the mistake equals the correction,
                // as sometimes Chat GPT might include such cases by mistake
                let filteredMistakes = mistakes.filter { $0.mistake != $0.correction }
                return filteredMistakes
            } catch {
                print("Error decoding JSON: \(error)")
                return []
            }
        } else {
            return []
        }
    }
}
