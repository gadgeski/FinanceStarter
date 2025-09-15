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
    @EnvironmentObject private var selection: RateSelectionStore      // 環境注入が必須

    @State private var baseInput: String = "USD"
    @State private var symbolInput: String = "JPY"

    var body: some View {
        NavigationStack {                                             // ← (2) 条件分岐の外に出す
            Group {
                if let b = selection.base, let s = selection.symbol {
                    // 選択済み → そのまま詳細チャート
                    RateDetailView(base: b, symbol: s, repository: repository)
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
                                    // ← (3) 正規化してからセット
                                    let b = baseInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                    let s = symbolInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                    guard !b.isEmpty, !s.isEmpty else { return }
                                    selection.set(b, s)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("チャート")                               // ← (4) 常にタイトルを表示
        }
    }
}
