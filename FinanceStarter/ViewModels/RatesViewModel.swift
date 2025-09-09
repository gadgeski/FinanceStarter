//
//  RatesViewModel.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import Foundation
import Observation

@MainActor
final class RatesViewModel: ObservableObject {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var base: String = "USD"
    @Published private(set) var rates: [(code: String, value: Double)] = []
    @Published var searchText: String = ""

    /// ウォッチリストは端末に保存（ユーザーごと）
    @Published var watchlist: Set<String> = {
        let saved = UserDefaults.standard.stringArray(forKey: "watchlist") ?? []
        return Set(saved)
    }() {
        didSet {
            UserDefaults.standard.set(Array(watchlist).sorted(), forKey: "watchlist")
        }
    }

    /// よく使う通貨（Picker 用）
    let commonBases: [String] = ["USD","JPY","EUR","GBP","AUD","CAD","CHF","CNY"]

    // [CHANGED] プレビューで自動フェッチを止められるようにする
    init(autoLoad: Bool = true) {                         // <-- [CHANGED]
        if autoLoad {                                     // <-- [CHANGED]
            Task { await refresh() }                      // <-- [CHANGED]
        }                                                 // <-- [CHANGED]
    }

    // [ADDED] プレビュー用（Loaded のモック）
    static func preview() -> RatesViewModel {             // <-- [ADDED]
        let vm = RatesViewModel(autoLoad: false)          // <-- [ADDED]
        vm.base = "USD"                                   // <-- [ADDED]
        vm.rates = [                                      // <-- [ADDED]
            (code: "JPY", value: 155.43),
            (code: "EUR", value: 0.92),
            (code: "GBP", value: 0.78),
            (code: "AUD", value: 1.49),
            (code: "CNY", value: 7.11)
        ]
        vm.state = .loaded                                // <-- [ADDED]
        return vm                                         // <-- [ADDED]
    }

    // [ADDED] プレビュー用（Loading のモック）
    static func previewLoading() -> RatesViewModel {      // <-- [ADDED]
        let vm = RatesViewModel(autoLoad: false)          // <-- [ADDED]
        vm.state = .loading                               // <-- [ADDED]
        return vm                                         // <-- [ADDED]
    }

    // [ADDED] プレビュー用（Error のモック）
    static func previewError() -> RatesViewModel {        // <-- [ADDED]
        let vm = RatesViewModel(autoLoad: false)          // <-- [ADDED]
        vm.state = .failed("サンプル: ネットワークに接続できません") // <-- [ADDED]
        return vm                                         // <-- [ADDED]
    }

    func setBase(_ newBase: String) {
        guard newBase != base else { return }
        base = newBase
        Task { await refresh() }
    }

    func refresh() async {
        state = .loading
        do {
            let result = try await ExchangeRateAPI.fetchLatest(base: base)
            // API は辞書で返すので、並びを安定化
            let list = result.rates
                .map { (code: $0.key, value: $0.value) }
                .sorted { $0.code < $1.code }
            self.rates = list
            self.state = .loaded
        } catch {
            self.state = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func toggleWatch(code: String) {
        if watchlist.contains(code) {
            watchlist.remove(code)
        } else {
            watchlist.insert(code)
        }
    }

    // 検索フィルタ
    var filteredRates: [(code: String, value: Double)] {
        guard !searchText.isEmpty else { return rates }
        let key = searchText.uppercased()
        return rates.filter { $0.code.contains(key) }
    }

    // セクション分け
    var watchlistRates: [(code: String, value: Double)] {
        filteredRates.filter { watchlist.contains($0.code) }
            .sorted { $0.code < $1.code }
    }

    var otherRates: [(code: String, value: Double)] {
        filteredRates.filter { !watchlist.contains($0.code) }
    }
}
