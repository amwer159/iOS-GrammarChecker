//
//  GrammarCompletionProvider.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation

protocol GrammarCompletionProvider {
    func createSystemPrompt(input: String) -> String
    func createUserText(input: String) -> String
}

internal class GrammarCompletionProviderImpl : GrammarCompletionProvider {
    
    //    func createSystemPrompt(input: String) -> String {
    //        let systemPrompt = """
    //        You are a grammar correction assistant.
    //            Please analyze the following text for grammar mistakes and return the corrections in JSON format.
    //            For each mistake, provide the incorrect word or phrase, the corrected version, the count of how many times the incorrect word appears in the text, and which instance of the word is incorrect (for cases where the word appears multiple times).
    //            If no mistakes exist, return an empty list of corrections.
    //            The JSON format should be an array of objects with the following structure:
    //            [
    //                {
    //                    "mistake": "wrong word or phrase",
    //                    "correction": "correct version",
    //                    "count": number of times the incorrect word appears,
    //                    "errorInstance": which occurrence of the word is incorrect (e.g. 1 for first, 2 for second)
    //                }
    //            ]
    //        """
    //        return systemPrompt
    //    }
    
    func createSystemPrompt(input: String) -> String {
        let systemPrompt = """
        You are a grammar correction assistant for English text.
        Analyze the following English text for grammar mistakes and return corrections in JSON format.
        For each mistake, include:
        - The incorrect word/phrase
        - The corrected version
        - How many times the incorrect word appears
        - The instance of the word that is incorrect (e.g., 1st, 2nd, etc.)
        
        If no mistakes, return an empty list.
        
        JSON format:
        [
            {
                "mistake": "wrong word",
                "correction": "correct word",
                "count": number of incorrect appearances,
                "errorInstance": instance of the mistake (e.g., 1 for first occurrence),
            }
        ]
        
        Future support for additional languages may be included.
        """
        return systemPrompt
    }
    
    
    func createUserText(input: String) -> String {
        return "Please check the following text for grammar mistakes: \(input)"
    }
}
