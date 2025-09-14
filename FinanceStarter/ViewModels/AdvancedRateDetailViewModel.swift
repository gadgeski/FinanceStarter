//
//  AdvancedRateDetailViewModel.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// ViewModels/AdvancedRateDetailViewModel.swift  // <-- [REPLACED: 構文エラー除去＋DI統一]
import Foundation

@MainActor
final class AdvancedRateDetailViewModel: ObservableObject {
    enum Range: Int, CaseIterable, Identifiable {
        case last7 = 7, last30 = 30
        var id: Int { rawValue }
        var title: String { self == .last7 ? "7日" : "30日" }
        var days: Int { rawValue }
    }

    @Published private(set) var base: String
    @Published private(set) var symbol: String
    @Published var selectedRange: Range = .last7
    @Published private(set) var points: [RatePoint] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // 指標（表示用）
    @Published private(set) var smaShort: [RatePoint] = []
    @Published private(set) var smaLong: [RatePoint] = []
    @Published private(set) var bbUpper: [RatePoint] = []
    @Published private(set) var bbMiddle: [RatePoint] = []
    @Published private(set) var bbLower: [RatePoint] = []
    @Published private(set) var rsi: [RatePoint] = []

    // 指標パラメータ（UIで変更可能）
    @Published var smaShortWindow: Int = 5
    @Published var smaLongWindow:  Int = 20
    @Published var bbWindow: Int = 20
    @Published var bbK: Double = 2.0
    @Published var rsiPeriod: Int = 14

    // しきい値 + “一度きり”モード
    @Published var upperThreshold: Double?
    @Published var lowerThreshold: Double?
    @Published var upperOnce: Bool = false
    @Published var lowerOnce: Bool = false
    @Published private(set) var upperFired: Bool = false
    @Published private(set) var lowerFired: Bool = false

    private let repo: ExchangeRateRepository
    private var thresholdKey: String { "thresh:\(base)->\(symbol)" }

    // ✅ Repository は必須注入
    init(base: String, symbol: String, repository: ExchangeRateRepository) {         // <-- [CHANGED]
        self.base = base.uppercased()
        self.symbol = symbol.uppercased()
        self.repo = repository
        restoreThreshold()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }                                                  // <-- [ADDED]
        do {
            let cal = Calendar(identifier: .gregorian)
            let end = Date()
            guard let start = cal.date(byAdding: .day, value: -selectedRange.days, to: end) else { return }
            let pts = try await repo.timeseries(base: base, symbol: symbol, start: start, end: end, useCache: true)
            self.points = pts
            computeIndicators()
            checkThresholdAndNotify()
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            self.points = []; self.smaShort = []; self.smaLong = []
            self.bbUpper = []; self.bbMiddle = []; self.bbLower = []; self.rsi = []
        }
    }

    // ========== 指標 ==========
    func computeIndicators() {
        self.smaShort = Indicators.SMA(points: points, window: smaShortWindow)
        self.smaLong  = Indicators.SMA(points: points, window: smaLongWindow)
        let bb = Indicators.Bollinger(points: points, window: bbWindow, k: bbK)
        self.bbMiddle = bb.middle; self.bbUpper = bb.upper; self.bbLower = bb.lower
        self.rsi = Indicators.RSI(points: points, period: rsiPeriod)
    }

    // ========== しきい値保存/復元 ==========
    private func restoreThreshold() {                                                // <-- [ADDED]
        if let data = UserDefaults.standard.data(forKey: thresholdKey),
           let t = try? JSONDecoder().decode(Threshold.self, from: data) {
            self.upperThreshold = t.upper
            self.lowerThreshold = t.lower
            self.upperOnce = t.upperOnce ?? false
            self.lowerOnce = t.lowerOnce ?? false
            self.upperFired = t.upperFired ?? false
            self.lowerFired = t.lowerFired ?? false
        }
    }

    func updateThresholds(upper: Double?, lower: Double?, upperOnce: Bool, lowerOnce: Bool) {
        self.upperThreshold = upper; self.lowerThreshold = lower
        self.upperOnce = upperOnce; self.lowerOnce = lowerOnce
        persistThreshold()
    }

    func resetOnceFlags() {
        upperFired = false; lowerFired = false; persistThreshold()
    }

    private func persistThreshold() {
        let t = Threshold(upper: upperThreshold, lower: lowerThreshold,
                          upperOnce: upperOnce, lowerOnce: lowerOnce,
                          upperFired: upperFired, lowerFired: lowerFired)
        if let data = try? JSONEncoder().encode(t) {
            UserDefaults.standard.set(data, forKey: thresholdKey)
        }
    }

    private func latestValue() -> Double? { points.last?.value }

    // ========== 通知（一度きり対応） ==========
    private func checkThresholdAndNotify() {                                        // <-- [ADDED back]
        guard let latest = latestValue() else { return }

        if let up = upperThreshold {
            if latest >= up, (!upperOnce || (upperOnce && !upperFired)) {
                NotificationManager.schedulePriceAlert(
                    base: base, symbol: symbol, current: latest,
                    message: "現在値 \(format(latest)) が上限 \(format(up)) を超えました。"
                )
                if upperOnce { upperFired = true; persistThreshold() }
            }
            if upperOnce && upperFired && latest < up { upperFired = false; persistThreshold() }
        }

        if let low = lowerThreshold {
            if latest <= low, (!lowerOnce || (lowerOnce && !lowerFired)) {
                NotificationManager.schedulePriceAlert(
                    base: base, symbol: symbol, current: latest,
                    message: "現在値 \(format(latest)) が下限 \(format(low)) を下回りました。"
                )
                if lowerOnce { lowerFired = true; persistThreshold() }
            }
            if lowerOnce && lowerFired && latest > low { lowerFired = false; persistThreshold() }
        }
    }

    func format(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 6
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }

    // プレビュー（このファイル内だけで完結）
    static func preview(base: String = "USD", symbol: String = "JPY") -> AdvancedRateDetailViewModel {
        struct MockRepository: ExchangeRateRepository {
            func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] {
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
                return pts
            }
        }
        let vm = AdvancedRateDetailViewModel(base: base, symbol: symbol, repository: MockRepository())
        vm.selectedRange = .last30
        Task { @MainActor in
            let cal = Calendar(identifier: .gregorian)
            let end = Date()
            let start = cal.date(byAdding: .day, value: -30, to: end)!
            vm.points = try await MockRepository().timeseries(base: base, symbol: symbol, start: start, end: end, useCache: true)
            vm.computeIndicators()
        }
        return vm
    }
}

// 保存用（“一度きり”状態含む）
private struct Threshold: Codable {                                                  // <-- [ADDED back]
    let upper: Double?
    let lower: Double?
    let upperOnce: Bool?
    let lowerOnce: Bool?
    let upperFired: Bool?
    let lowerFired: Bool?
}
