//
//  TimeseriesBridge.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Models/TimeseriesBridge.swift  // <-- [ADDED]
import Foundation

extension Timeseries { // = TimeseriesResponse
    /// 指定した通貨 `symbol` の時系列を [RatePoint] に正規化
    func ratePoints(for symbol: String) -> [RatePoint] {
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"

        return rates.compactMap { (dateStr, dict) -> RatePoint? in
            guard let v = dict[symbol], let d = df.date(from: dateStr) else { return nil }
            return RatePoint(date: d, value: v)
        }
        .sorted(by: { $0.date < $1.date })
    }
}
