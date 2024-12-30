//
//  GrammarWordsRepository.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import SwiftUI

protocol GrammarWordsRepository {
    var grammarWords: [GrammarWord] { get }
    var grammarWordsPublisher: Published<[GrammarWord]>.Publisher { get }
    
    func set(words: [GrammarWord])
    
    func update(_ id: UUID, updateBlock: (GrammarWord) -> GrammarWord)
    
    func clear()
}

internal class GrammarWordsRepositoryImpl : GrammarWordsRepository {
    static let shared: GrammarWordsRepository = GrammarWordsRepositoryImpl()
    
    @Published
    internal var grammarWords: [GrammarWord] = []
    
    // Expose a read-only publisher for grammarWords
    var grammarWordsPublisher: Published<[GrammarWord]>.Publisher {
        $grammarWords
    }
    
    func set(words: [GrammarWord]) {
        self.grammarWords = words
    }
    
    func update(_ id: UUID, updateBlock: (GrammarWord) -> GrammarWord) {
        if let index = grammarWords.firstIndex(where: { $0.id == id }) {
            let originalWord = grammarWords[index]
            let updatedWord = updateBlock(originalWord)
            grammarWords[index] = updatedWord
        }
    }
    
    func clear() {
        grammarWords = []
    }
}
