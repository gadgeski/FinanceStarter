//
//  ExchangeRateService.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Services/ExchangeRateService.swift
import Foundation

// MARK: - Service Protocol

protocol ExchangeRateService {
    /// 指定レンジの時系列を取得
    func timeseries(base: String, symbol: String, start: Date, end: Date) async throws -> Timeseries
}

// MARK: - API Config（エンドポイント仕様を外から注入）  // <-- [ADDED]

/// タイムシリーズAPIの“可変部分”をすべて設定で持つ
struct TimeseriesAPIConfig {                                         // <-- [ADDED]
    let baseURL: URL              // 例: https://api.example.com
    let path: String              // 例: /timeseries
    let baseParam: String         // 例: base
    let symbolParam: String       // 例: symbols
    let startParam: String        // 例: start_date
    let endParam: String          // 例: end_date
    let dateFormat: String        // 例: "yyyy-MM-dd"

    init(baseURL: URL,
         path: String,
         baseParam: String,
         symbolParam: String,
         startParam: String,
         endParam: String,
         dateFormat: String = "yyyy-MM-dd") {
        self.baseURL = baseURL
        self.path = path
        self.baseParam = baseParam
        self.symbolParam = symbolParam
        self.startParam = startParam
        self.endParam = endParam
        self.dateFormat = dateFormat
    }
}

// MARK: - Live Implementation (URLSession + Timeout + Config)

/// 実API呼び出し担当（URLSession のタイムアウトを明示）
final class LiveExchangeRateService: ExchangeRateService {
    private let session: URLSession
    private let api: TimeseriesAPIConfig                               // <-- [ADDED]

    /// - Parameters:
    ///   - session: タイムアウト設定済みURLSession（未指定なら内部で作成）
    ///   - api: タイムシリーズAPIのエンドポイント設定                     // <-- [ADDED]
    init(session: URLSession? = nil, api: TimeseriesAPIConfig) {        // <-- [CHANGED]
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 20
            self.session = URLSession(configuration: config)
        }
        self.api = api                                                  // <-- [ADDED]
    }

    func timeseries(base: String, symbol: String, start: Date, end: Date) async throws -> Timeseries {
        let url = try buildTimeseriesURL(base: base, symbol: symbol, start: start, end: end)
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Timeseries.self, from: data)
    }

    // MARK: URL Builder（TODO 警告を除去：実装に置き換え）                 // <-- [CHANGED]
    private func buildTimeseriesURL(base: String, symbol: String, start: Date, end: Date) throws -> URL {
        // 入力検証（start <= end）
        guard start <= end else { throw URLError(.badURL) }

        // 日付フォーマット
        let df = DateFormatter()
        df.calendar = .init(identifier: .gregorian)
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = api.dateFormat

        let startStr = df.string(from: start)
        let endStr = df.string(from: end)

        // URLComponentsで安全に構築
        guard var comps = URLComponents(url: api.baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        // パスの結合（末尾/先頭スラッシュを気にせず安全に繋ぐ）
        let basePath = comps.path.hasSuffix("/") ? String(comps.path.dropLast()) : comps.path
        let addPath = api.path.hasPrefix("/") ? api.path : "/\(api.path)"
        comps.path = basePath + addPath

        comps.queryItems = [
            URLQueryItem(name: api.baseParam, value: base),
            URLQueryItem(name: api.symbolParam, value: symbol),
            URLQueryItem(name: api.startParam, value: startStr),
            URLQueryItem(name: api.endParam, value: endStr)
        ]

        guard let url = comps.url else { throw URLError(.badURL) }
        return url
    }
}

// MARK: - Mock Implementation (Preview / Offline Tests)

/// プレビューやオフライン動作確認用のモック
struct MockExchangeRateService: ExchangeRateService {
    func timeseries(base: String, symbol: String, start: Date, end: Date) async throws -> Timeseries {
        // ダミー生成（サイン波）
        let cal = Calendar(identifier: .gregorian)
        var date = start
        var pts: [RatePoint] = []
        var i: Double = 0
        while date <= end {
            let v = 150.0 + 5.0 * sin(i / 6.0) + Double.random(in: -0.6...0.6)
            pts.append(RatePoint(date: date, value: v))
            date = cal.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86_400)
            i += 1
        }

        // ここはあなたの TimeseriesResponse の初期化に合わせて返してください。
        // 例）TimeseriesAlias = TimeseriesResponse, 且つ rates: [String: Double] の場合:
        // let df = DateFormatter(); df.calendar = .init(identifier: .gregorian); df.locale = .init(identifier: "en_US_POSIX"); df.dateFormat = "yyyy-MM-dd"
        // let rates = Dictionary(uniqueKeysWithValues: pts.map { (df.string(from: $0.date), $0.value) })
        // return TimeseriesResponse(rates: rates)

        fatalError("MockExchangeRateService: TimeseriesResponse の実初期化に合わせて返却を実装してください。")
    }
}
