//
//  ExchangeRates.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import Foundation

struct ExchangeRates: Decodable {
    let base: String
    let date: String
    let rates: [String: Double]
}
