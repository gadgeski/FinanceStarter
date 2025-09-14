//
//  Timeseries.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Models/Timeseries.swift  // <-- [CHANGED]
import Foundation

struct TimeseriesResponse: Decodable {
    let base: String
    let start_date: String
    let end_date: String
    let rates: [String: [String: Double]]   // "yyyy-MM-dd": { "JPY": 155.0 } の形
}

// ❗️以前ここにあった `struct RatePoint { ... }` は削除してください  // <-- [REMOVED]
