//
//  CSVBuilder.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Utils/CSVBuilder.swift
// 役割: 時系列CSVの文字列生成（ビューとは独立した関心事）                    // <-- [ADDED]
import Foundation

enum CSVBuilder {                                                                      // <-- [ADDED]
    static func timeseriesCSV(base: String, symbol: String, points: [RatePoint]) -> String {
        guard !points.isEmpty else { return "" }
        var s = "date,rate(\(base)->\(symbol))\n"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = .init(identifier: "en_US_POSIX")
        df.calendar = .init(identifier: .gregorian)
        for p in points {
            s += "\(df.string(from: p.date)),\(p.value)\n"
        }
        return s
    }
}
