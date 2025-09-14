//
//  ExchangeRateRepository.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Data/ExchangeRateRepository.swift
import Foundation

enum RepositoryError: Error, LocalizedError {
    case emptyData
    var errorDescription: String? {
        switch self {
        case .emptyData:
            return "データが取得できませんでした。期間や通貨を変更して再試行してください。"
        }
    }
}

protocol ExchangeRateRepository {
    func timeseries(
        base: String,
        symbol: String,
        start: Date,
        end: Date,
        useCache: Bool
    ) async throws -> [RatePoint]
}

final class LiveExchangeRateRepository: ExchangeRateRepository {

    private let service: ExchangeRateService
    private let cache: any CacheStore
    private let retry: RetryPolicy
    private let maxChartPoints = 600

    init(
        // service は必須注入（api 設定漏れを防ぐ）
        service: ExchangeRateService,
        cache: any CacheStore = DefaultCacheStore.shared,
        retry: RetryPolicy = .default
    ) {
        self.service = service
        self.cache = cache
        self.retry = retry
    }

    func timeseries(
        base: String,
        symbol: String,
        start: Date,
        end: Date,
        useCache: Bool
    ) async throws -> [RatePoint] {

        let cacheKey = "ts:\(base)->\(symbol):\(Int(start.timeIntervalSince1970)):\(Int(end.timeIntervalSince1970))"

        // キャッシュは [RatePoint] を保存/復元（Timeseries は直接保存しない）
        if useCache, let cached: [RatePoint] = try? cache.get(key: cacheKey, as: [RatePoint].self) {
            return downsampleIfNeeded(cached)
        }

        // API 呼び出し（リトライ適用）
        let ts: Timeseries = try await retry.execute {
            try await service.timeseries(base: base, symbol: symbol, start: start, end: end)
        }

        // 🔽 ここが今回の“1行修正”：symbol を渡して抽出する                           // <-- [CHANGED]
        let points = toRatePoints(ts, symbol: symbol)                                     // <-- [CHANGED]

        guard !points.isEmpty else { throw RepositoryError.emptyData }

        // [RatePoint] を Encodable としてキャッシュ保存
        try? cache.cache(key: cacheKey, encodable: points, ttl: 60 * 30)

        return downsampleIfNeeded(points)
    }

    // Timeseries(=TimeseriesResponse) → [RatePoint]
    // 以前: toRatePoints(_ ts: Timeseries) -> [RatePoint]
    // 変更: 通貨を選んで抽出するため symbol を受け取る                               // <-- [CHANGED]
    private func toRatePoints(_ ts: Timeseries, symbol: String) -> [RatePoint] {         // <-- [CHANGED]
        // TimeseriesBridge.swift の extension で提供されるメソッドを利用
        ts.ratePoints(for: symbol)                                                        // <-- [CHANGED]
    }

    // 簡易ダウンサンプル（min/max 抽出：ピークを残して点数を抑制）
    private func downsampleIfNeeded(_ points: [RatePoint]) -> [RatePoint] {
        let n = points.count
        guard n > maxChartPoints, maxChartPoints > 2 else { return points }

        // min/max の2点を1バケットから取り出す想定で幅を計算
        let bucketSize = Int(ceil(Double(n) / Double(maxChartPoints / 2)))
        var result: [RatePoint] = []
        result.reserveCapacity(min(n, maxChartPoints))

        var i = 0
        while i < n {
            let end = min(i + bucketSize, n)
            let slice = points[i..<end]
            if let minP = slice.min(by: { $0.value < $1.value }),
               let maxP = slice.max(by: { $0.value < $1.value }) {
                if minP.date <= maxP.date { result.append(minP); result.append(maxP) }
                else { result.append(maxP); result.append(minP) }
            } else if let only = slice.first {
                result.append(only)
            }
            i = end
        }

        if let first = points.first { result.insert(first, at: 0) }
        if let last  = points.last  { result.append(last) }

        let unique = Dictionary(grouping: result, by: { $0.date }).compactMap { $0.value.first }
        return unique.sorted(by: { $0.date < $1.date }).prefix(maxChartPoints).map { $0 }
    }
}
