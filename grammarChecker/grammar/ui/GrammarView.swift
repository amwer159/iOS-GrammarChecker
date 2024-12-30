//
//  GrammarView.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import SwiftUI

struct GrammarView: View {
    @State
    private var inputText: String = ""
    
    @StateObject
    private var keyboardVisibilityListner = KeyboardVisibilityListner()
    
    @StateObject
    private var viewModel = GrammarViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    VStack {
                        GrammarTextEditorContainer(
                            inputText: $inputText,
                            attributedText: $viewModel.attributedText,
                            onSubmit: {
                                viewModel.checkSpelling(for: inputText)
                                viewModel.check(input: inputText)
                                UIApplication.shared.dismissKeyboard()
                            },
                            onClear: {
                                viewModel.clear()
                            }
                        )
                        .frame(maxHeight: .infinity)
                        //                        .frame(maxWidth: .infinity, maxHeight: keyboardVisibilityListner.isKeyboardVisible ? .infinity : geometry.size.height / 2)
                        
                        if (viewModel.isLoading) {
                            ProgressView()
                        } else {
                            if (viewModel.incorrectWords.isEmpty) {
                                Spacer()
                            }
                        }
                        
                        if (!keyboardVisibilityListner.isKeyboardVisible && !viewModel.isLoading && !viewModel.incorrectWords.isEmpty) {
                            VStack {
                                Text("Mistakes count \(viewModel.incorrectWords.count)")
                                
                                List(viewModel.incorrectWords, id: \.id) { word in
                                    HStack {
                                        Text(word.mistake)
                                            .foregroundColor(.primary)
                                        Text(" -> ")
                                            .foregroundColor(.primary)
                                        Text(word.correction)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        Spacer()
                                        
                                        Button("Correct") {
                                            viewModel.correctWord(word: word)
                                        }
                                        .font(.system(size: 16, weight: .medium))
                                        .buttonStyle(.borderless)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10) // Create a rounded background
                                            .fill(viewModel.selectedGrammarWord?.id == word.id ? Color.blue.opacity(0.3) : Color(UIColor.systemGray5))
                                    )
                                    .listRowSeparator(.hidden)
                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                                    .listRowInsets(EdgeInsets())
                                    .simultaneousGesture(TapGesture().onEnded {
                                        viewModel.highlightWord(word: word)
                                    })
                                    .padding(.vertical, 4)
                                }
                                .listStyle(PlainListStyle())
                                .contentMargins(.horizontal, 16)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            //                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height / 2)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("GrammarChecker")
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    GrammarView()
}
