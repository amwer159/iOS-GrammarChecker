//
//  GrammarTextEditorView.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import SwiftUI

struct GrammarTextEditor: UIViewRepresentable {
    @Binding
    var inputText: String // The text which was entered by the user
    
    var attributedText: NSAttributedString // Highlighted text with errors
    var onTextChange: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if (attributedText.string.isEmpty) {
            uiView.text = inputText
            uiView.attributedText = NSAttributedString(string: inputText, attributes: defaultTextAttributes())
        } else {
            uiView.attributedText = attributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, defaultAttributes: defaultTextAttributes())
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrammarTextEditor
        let defaultAttributes: [NSAttributedString.Key: Any]
        
        init(_ parent: GrammarTextEditor, defaultAttributes: [NSAttributedString.Key: Any]) {
            self.parent = parent
            self.defaultAttributes = defaultAttributes
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.inputText = textView.text
            parent.attributedText = NSAttributedString(string: textView.text, attributes: defaultAttributes)
            parent.onTextChange?()
        }
        
        
    }
    
    private func defaultTextAttributes() -> [NSAttributedString.Key: Any]  {
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
