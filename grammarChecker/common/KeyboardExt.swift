//
//  KeyboardExt.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import SwiftUI

extension UIApplication {
    func dismissKeyboard() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
