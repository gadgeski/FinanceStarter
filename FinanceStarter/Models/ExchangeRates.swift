//
//  ExchangeRates.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

// Models/ExchangeRates.swift  // <-- [CHANGED]
import Foundation

// [CHANGED] Decodable -> Codable（= Encodable + Decodable）
struct ExchangeRates: Codable {                     // <-- [CHANGED]
    let base: String
    let date: String
    let rates: [String: Double]
}
