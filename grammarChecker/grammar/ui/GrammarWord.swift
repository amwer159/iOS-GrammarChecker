//
//  GrammarWord.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation

struct GrammarWord : Identifiable {
    let id = UUID()
    let mistake: String
    let correction: String
    let errorInstance: Int
    var range: NSRange
    var corrected: Bool = false
}
