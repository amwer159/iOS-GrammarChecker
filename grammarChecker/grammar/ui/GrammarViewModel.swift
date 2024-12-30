//
//  GrammarViewModel.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//
import Foundation
import Combine
import UIKit

class GrammarViewModel : ObservableObject {
    
    @Published var isLoading: Bool = false
    
    @Published var incorrectWords: [GrammarWord] = []
    @Published var attributedText: NSAttributedString = NSAttributedString()
    @Published var selectedGrammarWord: GrammarWord?
    
    private let grammarProvider: GrammarProvider
    private let grammarAttributedTextTransformer: GrammarAttributedTextTransformer
    private let grammarWordsRepository: GrammarWordsRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.grammarProvider = GrammarProviderImpl.shared
        self.grammarAttributedTextTransformer = GrammarAttributedTextTransformerImpl()
        self.grammarWordsRepository = GrammarWordsRepositoryImpl.shared
        
        grammarWordsRepository
            .grammarWordsPublisher
            .map { $0.filter { !$0.corrected } }
            .assign(to: \.incorrectWords, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        grammarWordsRepository.clear()
        cancellables.clear()
    }
    
    @MainActor
    func check(input: String) {
        isLoading = true
        Task {
            let result: Result<[GrammarMistake], Error> = await grammarProvider.check(input: input)
            
            switch result {
            case .success(let result):
                let (attributedText, words) = grammarAttributedTextTransformer.transform(from: input, mistakes: result)
                
                self.attributedText = attributedText
                grammarWordsRepository.set(words: words)
            case .failure(let error):
                print("viktor, error while check=\(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func highlightWord(word: GrammarWord) {
        self.selectedGrammarWord = word
        self.attributedText = grammarAttributedTextTransformer.highlightWord(attributedText: attributedText, selectedWord: word)
    }
    
    func correctWord(word: GrammarWord) {
        self.attributedText = grammarAttributedTextTransformer.correctWord(attributedText: attributedText, word: word)
    }
    
    struct GrammarWord1 {
        let mistake: String
        let correction: String
    }

    // Function to check the spelling of a given text and return a list of GrammarWord objects
    func checkSpelling(for text: String) -> [GrammarWord1] {
        let textChecker = UITextChecker()
        var grammarWords = [GrammarWord1]()
        
        // Configure NSLinguisticTagger to detect words
        let linguisticTagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        linguisticTagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        
        linguisticTagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: [.omitPunctuation, .omitWhitespace]) { (tag, tokenRange, stop) in
            let wordRange = Range(tokenRange, in: text)!
            let word = String(text[wordRange])
            
            // Check spelling for each word
            let misspelledRange = textChecker.rangeOfMisspelledWord(in: text, range: tokenRange, startingAt: 0, wrap: false, language: "en_US")
            
            if misspelledRange.location != NSNotFound {
                let misspelledWord = String(text[wordRange])
                
                // Fetch corrections for the misspelled word
                let corrections = textChecker.guesses(forWordRange: misspelledRange, in: text, language: "en") ?? []
                
                // Sort the corrections by Levenshtein distance
                let sortedGuesses = corrections.sorted {
                    levenshteinDistance(misspelledWord, $0) < levenshteinDistance(misspelledWord, $1)
                }
                
                if let bestCorrection = sortedGuesses.first {
                    print("viktor, bestCorrection=\(bestCorrection), \(sortedGuesses), \(corrections)")
                    
                    // Append the grammar word
                    let grammarWord = GrammarWord1(mistake: misspelledWord, correction: bestCorrection)
                    grammarWords.append(grammarWord)
                }
            }
        }
        
        return grammarWords
    }

    // Function to compute Levenshtein distance between two strings
    func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aCount = a.count
        let bCount = b.count
        
        guard aCount != 0 else { return bCount }
        guard bCount != 0 else { return aCount }
        
        var matrix = Array(repeating: Array(repeating: 0, count: bCount + 1), count: aCount + 1)
        
        for i in 0...aCount {
            matrix[i][0] = i
        }
        
        for j in 0...bCount {
            matrix[0][j] = j
        }
        
        for i in 1...aCount {
            for j in 1...bCount {
                if Array(a)[i-1] == Array(b)[j-1] {
                    matrix[i][j] = matrix[i-1][j-1]
                } else {
                    matrix[i][j] = min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + 1)
                }
            }
        }
        
        return matrix[aCount][bCount]
    }

    
    func clear() {
        self.selectedGrammarWord = nil
        self.attributedText = NSAttributedString()
//        self.incorrectWords = []
        self.grammarWordsRepository.clear()
        print("viktor clear(). size=\(incorrectWords.count)")
    }
        
}
