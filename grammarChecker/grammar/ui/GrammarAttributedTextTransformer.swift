//
//  GrammerAttributedTextBuilder.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import SwiftUI

protocol GrammarAttributedTextTransformer {
//    @Binding
//    var attributedText: String? { get }
    
    func transform(from input: String, mistakes: [GrammarMistake]) -> (attributedText: NSAttributedString, words: [GrammarWord])
    
    func highlightWord(attributedText: NSAttributedString, selectedWord: GrammarWord) -> NSAttributedString
    
    func correctWord(attributedText: NSAttributedString?, word: GrammarWord) -> NSAttributedString
}

internal class GrammarAttributedTextTransformerImpl : GrammarAttributedTextTransformer {
    
    private let grammarWordsRepository: GrammarWordsRepository
    
    init(grammarWordsRepository: GrammarWordsRepository = GrammarWordsRepositoryImpl.shared) {
        self.grammarWordsRepository = grammarWordsRepository
    }
    
//    @Binding
//    var attributedText: String? = nil
    
    func transform(from input: String, mistakes: [GrammarMistake]) -> (attributedText: NSAttributedString, words: [GrammarWord]) {
        return highlightMistakes(inputText: input, mistakes: mistakes)
    }
    
    func highlightWord(attributedText: NSAttributedString, selectedWord: GrammarWord) -> NSAttributedString {
        if (selectedWord.corrected) {
            return attributedText
        }
        // Create a mutable copy of the attributed text
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // Reset the color for the entire string (optional, based on your needs)
        mutableAttributedText.addAttribute(.backgroundColor, value: UIColor.clear, range: NSRange(location: 0, length: attributedText.length))
        
        // Check if the word was found
        if selectedWord.range.location != NSNotFound {
            // Highlight the selected word
            mutableAttributedText.addAttribute(.backgroundColor, value: UIColor.systemGray3, range: selectedWord.range)
            mutableAttributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18.0), range: selectedWord.range)
        }
        
        return mutableAttributedText // Return the modified attributed string
    }
    
    func correctWord(attributedText: NSAttributedString?, word: GrammarWord) -> NSAttributedString {
        // Extract the current attributed text as mutable
        guard let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return NSAttributedString() // Return an empty attributed string if there's no text
        }
        
        // Replace the incorrect word with the correction
        mutableAttributedText.replaceCharacters(in: word.range, with: word.correction)
        
        // Get the new range after replacement (since correction may have different length)
        let correctedWordRange = NSRange(location: word.range.location, length: word.correction.utf16.count)
        
        mutableAttributedText.setAttributes(defaultTextAttributes(attributedText: mutableAttributedText), range: correctedWordRange)
        
        grammarWordsRepository.update(word.id) { existingWord in
            var mutableWord = existingWord
            mutableWord.corrected = true
            return mutableWord
        }
        
        // Check if the corrected word length is different from the original
        let originalWordLength = word.range.length
        let correctedWordLength = word.correction.utf16.count
        
        if (originalWordLength != correctedWordLength) {
            // Recalculate ranges for other mistakes
            let updatedText = mutableAttributedText.string
            let incorrectWords = grammarWordsRepository.grammarWords.filter { !$0.corrected }
            print("viktor, wordsCount, \(incorrectWords.count)")
            for grammarWord in incorrectWords {
                // Skip recalculating for the word that was just corrected
                if grammarWord.corrected || grammarWord.mistake == word.mistake {
                    continue
                }
                
                // Find new range for remaining mistakes after the correction
                let range: NSRange? = if (grammarWord.errorInstance > 1) {
                    findInstance(of: grammarWord.mistake, in: updatedText, instance: grammarWord.errorInstance)
                } else {
                    findFirstInstance(inputText: updatedText, word: grammarWord.mistake)
                }
                
                guard let validRange = range else {
                    continue
                }
                
                grammarWordsRepository.update(grammarWord.id) { existingWord in
                    var mutableWord = existingWord
                    mutableWord.range = validRange
                    return mutableWord
                }
                
                mutableAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: validRange)
                mutableAttributedText.addAttribute(.foregroundColor, value: UIColor.red, range: validRange)
//                mutableAttributedText.addAttribute(.font, value: defaultFont, range: validRange) // Set font for mistakes if needed
            }
        }
        
        return mutableAttributedText
    }
    
    private func highlightMistakes(inputText: String, mistakes: [GrammarMistake])
    -> (attributedText: NSAttributedString, words: [GrammarWord]) {
        let attributedString = NSMutableAttributedString(string: inputText)
        
        // Set a default font for the entire string
        attributedString.setAttributes(
            defaultTextAttributes(attributedText: attributedString), range: NSRange(location: 0, length: inputText.count)
        )
        
        var grammarWords: [GrammarWord] = []
        
        for mistake in mistakes {
            let range: NSRange? = if (mistake.errorInstance > 1) {
                findInstance(of: mistake.mistake, in: inputText, instance: mistake.errorInstance)
            } else {
                findFirstInstance(inputText: inputText, word: mistake.mistake)
            }
            
            guard let validRange = range else {
                continue
            }
            
            grammarWords.append(mistake.toWord(range: validRange))
            
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: validRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: validRange)
//            attributedString.addAttribute(.font, value: defaultFont, range: validRange) // Set font for mistakes if needed
        }
        
        return (attributedString, grammarWords)
    }
    
    private func findFirstInstance(inputText: String, word: String) -> NSRange? {
        guard let range = inputText.range(of: word) else {
            return nil // Word not found
        }
        
        let startIndex = inputText.distance(from: inputText.startIndex, to: range.lowerBound)
        let endIndex = inputText.distance(from: inputText.startIndex, to: range.upperBound)
        
        return NSRange(location: startIndex, length: endIndex - startIndex)
    }
    
    private func findInstance(of word: String, in text: String, instance: Int) -> NSRange? {
        var currentInstance = 0
        let textCount = text.utf16.count
        var searchRange = NSRange(location: 0, length: textCount) // utf16 is used to handle string length properly with NSRange
        
        // Loop to find the correct instance of the word
        while (searchRange.location < textCount) {
            let range = (text as NSString).range(of: word, options: [], range: searchRange)
            
            if range.location == NSNotFound {
                break // No more instances found, exit loop
            }
            
            currentInstance += 1
            
            // If this is the correct instance, return the range
            if currentInstance == instance {
                return range
            }
            
            // Update the search range to continue searching after the current occurrence
            let newLocation = range.location + range.length
            searchRange = NSRange(location: newLocation, length: text.utf16.count - newLocation)
        }
        
        return nil // Return nil if the correct instance is not found
    }
    
    private func defaultTextAttributes(attributedText: NSMutableAttributedString) -> [NSAttributedString.Key: Any]  {
        // Normalize the corrected word by removing highlights (e.g., underline, color)
        let defaultFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: defaultFont,
            .foregroundColor: UIColor.black, // Assuming default text color is black
//            .underlineStyle: NSUnderlineStyle.RawValue
        ]
        
        return defaultAttributes
    }
}
