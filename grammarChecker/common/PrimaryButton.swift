//
//  PrimaryButton.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(12)
        .background(
            .blue,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .buttonStyle(.plain)
    }
}

#Preview {
    PrimaryButton(title: "Click me", action: {})
}

