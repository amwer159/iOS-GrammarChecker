//
//  IconButton.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import SwiftUI

struct IconButton : View {
    var iconName: String
    var tint: Color?
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(tint)
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button styling
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        IconButton(iconName: "heart.fill") {}
    }
}
