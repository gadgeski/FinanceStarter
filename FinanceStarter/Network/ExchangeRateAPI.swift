//
//  ExchangeRateAPI.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import Foundation

enum APIError: Error, LocalizedError {
    case badURL
    case transport(Error)
    case badStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "不正なURLです。"
        case .transport(let err): return "通信エラー: \(err.localizedDescription)"
        case .badStatus(let code): return "サーバーステータス異常 (\(code))"
        case .decoding(let err): return "デコード失敗: \(err.localizedDescription)"
        }
    }
}

enum ExchangeRateAPI {
    /// APIキー不要: https://api.exchangerate.host/latest?base=USD
    static func fetchLatest(base: String) async throws -> ExchangeRates {
        guard var components = URLComponents(string: "https://api.exchangerate.host/latest") else {
            throw APIError.badURL
        }
        components.queryItems = [
            .init(name: "base", value: base.uppercased())
        ]
        guard let url = components.url else { throw APIError.badURL }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw APIError.badStatus(http.statusCode)
            }
            do {
                return try JSONDecoder().decode(ExchangeRates.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch {
            throw APIError.transport(error)
        }
    }
}
