//
//  RatesViewModel.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// ViewModels/RatesViewModel.swift  // <-- [REPLACED] ContentView が期待するAPIに合わせて復元
import Foundation

@MainActor
final class RatesViewModel: ObservableObject {
    // 画面状態
    enum State {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published var base: String = "USD"                       // Picker で変更
    @Published var searchText: String = ""                    // .searchable で使用

    // ウォッチリスト（UserDefaults 保存）
    @Published var watchlist: Set<String> = [] {
        didSet { persistWatchlist() }
    }

    // 一覧表示用の内部モデル
    struct RateItem: Identifiable {
        var id: String { code }
        let code: String
        let value: Double?
    }

    // 取得済みの全レート
    @Published private(set) var allRates: [RateItem] = []

    // UI から参照される派生プロパティ
    var commonBases: [String] { ["USD", "EUR", "JPY", "GBP"] }       // よく使う基準通貨

    var watchlistRates: [RateItem] {
        filtered(items: allRates.filter { watchlist.contains($0.code) })
    }

    var otherRates: [RateItem] {
        filtered(items: allRates.filter { !watchlist.contains($0.code) })
    }

    private let repo: ExchangeRateRepository

    init(repository: ExchangeRateRepository) {
        self.repo = repository
        restoreWatchlist()
    }

    // 検索フィルタ
    private func filtered(items: [RateItem]) -> [RateItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !q.isEmpty else { return items }
        return items.filter { $0.code.contains(q) }
    }

    // データ取得（直近1日で「代表的な通貨」を取得）
    func refresh() async {
        state = .loading
        let universe = universeForBase(base)                 // 表示対象の通貨コード
        let cal = Calendar(identifier: .gregorian)
        let end = Date()
        guard let start = cal.date(byAdding: .day, value: -1, to: end) else {
            state = .failed("日付計算に失敗しました"); return
        }

        do {
            var results: [RateItem] = []
            for code in universe {
                let pts = try await repo.timeseries(base: base, symbol: code, start: start, end: end, useCache: true)
                results.append(RateItem(code: code, value: pts.last?.value))
            }
            self.allRates = results.sorted { $0.code < $1.code }
            self.state = .loaded
        } catch {
            self.state = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            self.allRates = []
        }
    }

    // Universe（基準通貨ごとに表示する代表コード）
    private func universeForBase(_ base: String) -> [String] {
        let common = ["JPY","EUR","GBP","AUD","CAD","CHF","CNY","KRW","NZD","SGD"]
        return common.filter { $0 != base.uppercased() }
    }

    // ウォッチリスト操作
    func toggleWatch(code: String) {
        if watchlist.contains(code) { watchlist.remove(code) } else { watchlist.insert(code) }
    }

    // 基準通貨変更
    func setBase(_ newBase: String) {
        guard newBase.uppercased() != base else { return }
        base = newBase.uppercased()
        Task { await refresh() }
    }

    // 保存/復元
    private func persistWatchlist() {
        let arr = Array(watchlist).sorted()
        UserDefaults.standard.set(arr, forKey: "watchlist.codes")
    }

    private func restoreWatchlist() {
        if let arr = UserDefaults.standard.array(forKey: "watchlist.codes") as? [String] {
            self.watchlist = Set(arr)
        }
    }
}

#if DEBUG
// Preview 用の便利コンストラクタを復活
extension RatesViewModel {
    static func preview() -> RatesViewModel {
        struct MockRepo: ExchangeRateRepository {
            func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] {
                let cal = Calendar(identifier: .gregorian)
                var d = start; var i: Double = 0; var pts: [RatePoint] = []
                while d <= end {
                    let v = 100 + Double(abs(symbol.hashValue % 50)) + 5 * sin(i/6)
                    pts.append(RatePoint(date: d, value: v))
                    d = cal.date(byAdding: .hour, value: 6, to: d) ?? d.addingTimeInterval(21_600)
                    i += 1
                }
                return pts
            }
        }
        let vm = RatesViewModel(repository: MockRepo())
        vm.base = "USD"
        vm.watchlist = ["JPY","EUR"]
        vm.allRates = ["JPY","EUR","GBP","AUD","CAD"].map { .init(code: $0, value: Double.random(in: 90...160)) }
        vm.state = .loaded
        return vm
    }

    static func previewLoading() -> RatesViewModel {
        struct MockRepo: ExchangeRateRepository {
            func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] { [] }
        }
        let vm = RatesViewModel(repository: MockRepo())
        vm.state = .loading
        return vm
    }

    static func previewError() -> RatesViewModel {
        struct MockRepo: ExchangeRateRepository {
            enum E: Error { case sample }
            func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] { throw E.sample }
        }
        let vm = RatesViewModel(repository: MockRepo())
        vm.state = .failed("サンプルエラー")
        return vm
    }
}
#endif
