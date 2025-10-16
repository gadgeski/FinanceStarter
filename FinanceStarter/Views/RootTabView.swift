//
//  RootTabView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/RootTabView.swift
import SwiftUI

struct RootTabView: View {
    enum Tab: Hashable { case home, alerts, chart, settings }

    let repository: ExchangeRateRepository
    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {

            // 1) ホーム（= ContentView を内包）
            RatesHomeTab(repository: repository)
                .tabItem { Label("ホーム", systemImage: "house") }
                .tag(Tab.home)
                .accessibilityLabel("ホーム")

            // 2) アラート
            AlertsView(repository: repository)
                .tabItem { Label("アラート", systemImage: "bell") }
                .tag(Tab.alerts)
                .accessibilityLabel("アラート")

            // 3) チャート
            ChartTabView(repository: repository)
                .tabItem { Label("チャート", systemImage: "chart.xyaxis.line") }
                .tag(Tab.chart)
                .accessibilityLabel("チャート")

            // 4) 設定
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(Tab.settings)
                .accessibilityLabel("設定")
        }
        .environment(\.tabSelection, $selection)
        // <-- [CHANGED] 子ビューからタブ切替できる Binding を Root で一元供給
        #if DEBUG
        .onChange(of: selection) { old, new in
            print("RootTabView Tab changed: \(old) -> \(new)")
            // <-- [CHANGED] デバッグ用ログ（不要なら削除可）
        }
        #endif
    }
}

// MARK: - 環境キー（このファイルに一元化してください）
private struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<RootTabView.Tab>? = nil
}
extension EnvironmentValues {
    var tabSelection: Binding<RootTabView.Tab>? {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}
// ↑↑↑ 他ファイルで同名キー/拡張を定義すると衝突します。プロジェクト内で本定義を唯一にしてください。 // <-- [CHANGED]

// MARK: - ホームタブのラッパ（ContentView + VM をここで保持）
private struct RatesHomeTab: View {
    let repository: ExchangeRateRepository
    @StateObject private var vm: RatesViewModel

    init(repository: ExchangeRateRepository) {
        self.repository = repository
        _vm = StateObject(wrappedValue: RatesViewModel(repository: repository))
    }

    var body: some View {
        ContentView(repository: repository, viewModel: vm)
            .accessibilityLabel("ホーム")
            .accessibilityHint("為替レート一覧を表示します")
    }
}

#if DEBUG
// MARK: - Preview（RateSelectionStore は App 側で注入される想定。ここでは最小限のスタブだけでOK）
private struct MockRepo: ExchangeRateRepository {
    func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] {
        let cal = Calendar(identifier: .gregorian)
        var d = start; var i: Double = 0; var pts: [RatePoint] = []
        while d <= end {
            let v = 150 + 5 * sin(i/6) + Double.random(in: -0.5...0.5)
            pts.append(RatePoint(date: d, value: v))
            d = cal.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86_400)
            i += 1
        }
        return pts
    }
}

#Preview {
    RootTabView(repository: MockRepo())
        .environmentObject(RateSelectionStore())
    // ← ChartTabView が @EnvironmentObject を要求するため Preview でも注入
}
#endif
