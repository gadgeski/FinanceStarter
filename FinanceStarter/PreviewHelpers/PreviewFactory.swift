//
//  PreviewFactory.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// PreviewHelpers/PreviewFactory.swift（差し替え）
import Foundation

@MainActor
enum PreviewFactory {
    // 軽量モック（最小限でOK）
    private struct MockRepo: ExchangeRateRepository {
        func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] {
            let cal = Calendar(identifier: .gregorian)
            var d = start; var i: Double = 0; var pts: [RatePoint] = []
            while d <= end {
                let v = 150 + 5 * sin(i/6) + Double.random(in: -0.4...0.4)
                pts.append(RatePoint(date: d, value: v))
                d = cal.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86_400)
                i += 1
            }
            return pts
        }
    }

    // ここで .preview() を使わない（存在しないため）。直接初期化する。
    static func ratesVM() -> RatesViewModel {
        RatesViewModel(repository: MockRepo())   // ← これでコンパイル通ります
        // 必要なら Task { await vm.load(...) } のように公開APIでデータ投入してください
    }
}
