//
//  RateSelectionStore.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Models/RateSelectionStore.swift
import Foundation

final class RateSelectionStore: ObservableObject {             // <-- [ADDED]
    @Published var base: String?                               // <-- [ADDED]
    @Published var symbol: String?                             // <-- [ADDED]
    func set(_ base: String, _ symbol: String) {               // <-- [ADDED]
        self.base = base.uppercased()
        self.symbol = symbol.uppercased()
    }
}
