//
//  RetryPolicy.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Data/RetryPolicy.swift
import Foundation

public struct RetryPolicy {
    public let maxAttempts: Int           // 最大試行回数（成功1回＋失敗のリトライ合計）
    public let initialBackoff: TimeInterval
    public let multiplier: Double
    public let maxBackoff: TimeInterval
    public let jitterRatio: Double        // 0.0...1.0（待機に±jitter）

    public static let `default` = RetryPolicy(
        maxAttempts: 3,                   // 例: 初回＋リトライ2回
        initialBackoff: 0.5,
        multiplier: 2.0,
        maxBackoff: 4.0,
        jitterRatio: 0.2
    )

    public init(maxAttempts: Int, initialBackoff: TimeInterval, multiplier: Double, maxBackoff: TimeInterval, jitterRatio: Double) {
        self.maxAttempts = maxAttempts
        self.initialBackoff = initialBackoff
        self.multiplier = multiplier
        self.maxBackoff = maxBackoff
        self.jitterRatio = jitterRatio
    }

    // 汎用 async リトライ（URLError の一部や一時的エラーだけ再試行）
    public func execute<T>(_ op: () async throws -> T) async throws -> T {
        var attempt = 0
        var delay = initialBackoff

        while true {
            do {
                return try await op()
            } catch {
                attempt += 1
                // 再試行すべきか判定
                if attempt >= maxAttempts || !shouldRetry(error: error) {
                    throw error
                }
                // ジッタ付きバックオフ
                let jitter = delay * jitterRatio
                let lower = max(0, delay - jitter)
                let upper = delay + jitter
                let wait = Double.random(in: lower...upper)
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                delay = min(delay * multiplier, maxBackoff)
            }
        }
    }

    private func shouldRetry(error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet,
                 .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return true
            default: return false
            }
        }
        // サーバ5xx系などを必要に応じて拾いたい場合は、あなたの実装のエラー型に合わせて拡張してください
        return false
    }
}
