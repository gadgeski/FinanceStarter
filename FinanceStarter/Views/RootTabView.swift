//
//  RootTabView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/RootTabView.swift（置き換え or 差分）
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
            ChartTabView(repository: repository)   // 既存がなければミニ版を後述
                .tabItem { Label("チャート", systemImage: "chart.xyaxis.line") }
                .tag(Tab.chart)
                .accessibilityLabel("チャート")

            // 4) 設定
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
                .tag(Tab.settings)
                .accessibilityLabel("設定")
        }
        // 子ビューからタブを切り替えるための Binding を環境に流す
        .environment(\.tabSelection, $selection)  // 下の環境キーを追加
    }
}


// MARK: - 環境キー（子からタブ切替可能に）
private struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<RootTabView.Tab>? = nil
}
extension EnvironmentValues {
    var tabSelection: Binding<RootTabView.Tab>? {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}

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
