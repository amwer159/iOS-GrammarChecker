//
//  CancellablesExt.swift
//  grammarChecker
//
//  Created by Ilin, Viktor (Contractor) on 30/12/2024.
//

import Foundation
import Combine

extension Set<AnyCancellable> {
    
    mutating func clear() {
        self.forEach({ $0.cancel() })
        self.removeAll()
    }
}
