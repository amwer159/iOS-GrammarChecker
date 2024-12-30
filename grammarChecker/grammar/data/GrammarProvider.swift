//
//  GrammarProvider.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import ChatGPTSwift

protocol GrammarProvider {
    func check(input: String) async -> Result<[GrammarMistake], Error>
}

internal class GrammarProviderImpl : GrammarProvider {
    static let shared: GrammarProvider = GrammarProviderImpl()
    
    private let completionProvider: GrammarCompletionProvider
    private let grammarMistakeParser: GrammarMistakeParser
    private let api: ChatGPTAPI
    
    init(
        completionProvider: GrammarCompletionProvider = GrammarCompletionProviderImpl(),
        grammarMistakeParser: GrammarMistakeParser = GrammarMistakeParser()
    ) {
        self.completionProvider = completionProvider
        self.grammarMistakeParser = grammarMistakeParser
        self.api = ChatGPTAPI(
            apiKey: "")
    }
    
    func check(input: String) async -> Result<[GrammarMistake], Error> {
        print("viktor Request for translation")
        do {
            let response = try await api.sendMessage(
                text: completionProvider.createUserText(input: input),
                model: .gpt_hyphen_4,
                systemText: completionProvider.createSystemPrompt(input: input)
            )
            print("viktor, response=\(response)")
            
            let parsedResponse = grammarMistakeParser.parse(response: trimOutsideBrackets(response: response))
            
            return .success(parsedResponse.map { $0.toMistake() })
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
    // Sometimes chat gpt returns response which starts/ends from """, ```, '''
    private func trimTripleQuotes(response: String) -> String {
        var trimmed = response
        let tripleQuotes = ["\"\"\"", "'''", "```"]
        
        for quote in tripleQuotes {
            if (trimmed.hasPrefix(quote) && trimmed.hasSuffix(quote)) {
                trimmed = String(trimmed.dropFirst(3).dropLast(3))
            }
        }
        
        return trimmed
    }
    
    private func trimOutsideBrackets(response: String) -> String {
        guard let startIndex = response.firstIndex(of: "["),
              let endIndex = response.lastIndex(of: "]") else {
            // Return the original string if no brackets are found
            return response
        }
        
        // Extract the substring between the brackets, inclusive
        let trimmedRange = startIndex...endIndex
        return String(response[trimmedRange])
    }
}
