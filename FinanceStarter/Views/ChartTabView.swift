//
//  ChartTabView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/ChartTabView.swift
import SwiftUI

struct ChartTabView: View {
    let repository: ExchangeRateRepository
    @EnvironmentObject private var selection: RateSelectionStore
    // 環境注入が必須

    @State private var baseInput: String = "USD"
    @State private var symbolInput: String = "JPY"

    var body: some View {
        NavigationStack {
            // <-- [CHANGED] 分岐の外に出してスタックを安定化
            Group {
                if let b = selection.base, let s = selection.symbol {
                    // 選択済み → そのまま詳細チャート
                    RateDetailView(
                        base: b,
                        symbol: s,
                        repository: repository
                    )
                    .id("pair:\(b)->\(s)")
                    // <-- [ADDED] 通貨ペア変更時に確実に再生成させる（状態の取り違え防止）
                } else {
                    // 未選択 → 案内＋手動入力で表示
                    Form {
                        Section {
                            Text("アラートタブの行を長押し/スワイプして「チャートで表示」を選ぶと、ここに通貨ペアが反映されます。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Section("手動で表示する") {
                            HStack {
                                TextField("基準 (例: USD)", text: $baseInput)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                Text("→")
                                TextField("通貨 (例: JPY)", text: $symbolInput)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                Button("表示") {
                                    // 入力を正規化してからセット
                                    let b = baseInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                    let s = symbolInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                    guard !b.isEmpty, !s.isEmpty else { return }
                                    selection.set(b, s)
                                }
                                .buttonStyle(.borderedProminent)
                                .accessibilityLabel("指定した通貨ペアで表示")
                            }
                        }
                    }
                }
            }
            .navigationTitle("チャート")
            // ↑ 常にタイトルを表示
            #if DEBUG
            .onChange(of: selection.base) { _, newValue in
                print("ChartTabView base changed:", newValue ?? "nil")
                // デバッグ用
            }
            .onChange(of: selection.symbol) { _, newValue in
                print("ChartTabView symbol changed:", newValue ?? "nil")
                // デバッグ用
            }
            #endif
        }
    }
}

#if DEBUG
// MARK: - Preview
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

#Preview("未選択（フォーム表示）") {
    let store = RateSelectionStore()
    // <-- [ADDED] Preview でも環境を注入
    return ChartTabView(repository: MockRepo())
        .environmentObject(store)
}

#Preview("選択済み（USD/JPY 表示）") {
    let store = RateSelectionStore()
    store.set("USD", "JPY")
    return ChartTabView(repository: MockRepo())
        .environmentObject(store)
}
#endif
