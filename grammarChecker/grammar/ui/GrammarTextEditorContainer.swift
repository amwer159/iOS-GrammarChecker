//
//  GrammarTextEditorContainer.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import SwiftUI

struct GrammarTextEditorContainer : View {
    @Binding
    var inputText: String
    
    @Binding
    var attributedText: NSAttributedString
    
    @FocusState
    private var isTextEditorFocused: Bool
    
    var onTextChange: (() -> Void)? = nil
    var onSubmit: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if !inputText.isEmpty {
                    Spacer()
                    
                    Button("Clear") {
                        inputText = ""
                        onClear?()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .buttonStyle(.automatic)
                    .transition(.opacity)
                } else {
                    Spacer()
                }
            }.animation(.easeInOut, value: inputText.isEmpty)
            
            GrammarTextEditor(
                inputText: $inputText,
                attributedText: attributedText,
                onTextChange: onTextChange
            )
            .scrollContentBackground(.hidden)
            .submitLabel(.done)
            .accentColor(.blue)
            .focused($isTextEditorFocused) // Focus modifier for keyboard control
            .submitLabel(.done)
            .onSubmit {
                self.isTextEditorFocused = false
                onSubmit?()
            }
            .onAppear {
                // Automatically show the keyboard when the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isTextEditorFocused = true
                }
            }
            
            HStack {
                Spacer()
                
                if (inputText.isEmpty) {
                    PrimaryButton(title: "Default") {
                        inputText = "Th quick brown fox jumps over the lazi dog. Its tail waz too short too reach the moon, but he stil tried and faild. Everyone watching laffed, not noticing there own mistakes in plain site."
                    }
                }
                
                if (!inputText.isEmpty) {
                    PrimaryButton(title: "Correct", action: {
                        onSubmit?()
                    })
                }
            }
        }
        .padding()
        .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
    }
}

struct GrammarTextEditorContainer_Previews: PreviewProvider {
    static var previews: some View {
        GrammarTextEditorContainer(
            inputText: .constant("Lorem ipsum"),
            attributedText: .constant(NSAttributedString())
        )
    }
}
