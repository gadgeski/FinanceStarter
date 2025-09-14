//
//  RootTabView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/RootTabView.swift  // <-- [ADDED]
// 動作確認/ConttentView → RootTabView
// Views/RootTabView.swift
import SwiftUI

struct RootTabView: View {
    let repository: ExchangeRateRepository        // <-- [CHANGED] 受け取り必須

    var body: some View {
        TabView {
            // ⛳️ 下記を修正
            AlertsView(repository: repository) // <-- [CHANGED] 引数なし -> repository を渡す                .tabItem { Label("アラート", systemImage: "bell") }

            NavigationStack {
                // 必要に応じて ChartTabView(repository:) を使う構成でもOK
                RateDetailView(base: "USD", symbol: "JPY", repository: repository) // <-- [CHANGED]
            }
            .tabItem { Label("チャート", systemImage: "chart.xyaxis.line") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
    }
}

// MARK: - Preview（ここでも repository を渡す！）
#Preview {
    struct MockRepo: ExchangeRateRepository {
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
    return RootTabView(repository: MockRepo())     // <-- [CHANGED] Preview でも注入
}
