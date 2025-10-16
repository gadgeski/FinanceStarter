//
//  FinanceStarterApp.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

// App/FinanceStarterApp.swift
import SwiftUI

@main
struct FinanceStarterApp: App {
    private let repository: ExchangeRateRepository
    // 依存を起動時に構築

    init() {
        // 実API仕様に合わせて置き換えてください
        let apiCfg = TimeseriesAPIConfig(
            baseURL: URL(string: "https://example.invalid")!,
            // 例: プレースホルダ
            path: "/timeseries",
            baseParam: "base",
            symbolParam: "symbols",
            startParam: "start_date",
            endParam: "end_date",
            dateFormat: "yyyy-MM-dd"
        )
        let service = LiveExchangeRateService(api: apiCfg)
        self.repository = LiveExchangeRateRepository(service: service)
    }

    var body: some Scene {
        WindowGroup {
            // 起動ビューが ContentView でも RootTabView でもOK。
            // どちらにも repository を渡す（下は RootTabView 起動例）。
            RootTabView(repository: repository)
                .environmentObject(RateSelectionStore())
            // ↑ [CHANGED] Appルートで一括注入（ChartTabView の @EnvironmentObject を満たす）
            // ↑ 上記が無いと ChartTabView で落ちます（"No ObservableObject of type RateSelectionStore found"）
            // ⚠️ ランタイムではこの注入を1回だけにしてください（他画面で重ねない）。Preview での個別注入は別レイヤーなので問題ありません。
            // ContentView(repository: repository) でも可（ContentView側が受け取れるなら）
        }
    }
}
