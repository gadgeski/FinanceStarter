//
//  ChartTabView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/ChartTabView.swift
import SwiftUI

struct ChartTabView: View {                                      // <-- [ADDED]
    let repository: ExchangeRateRepository
    @EnvironmentObject private var selection: RateSelectionStore  // <-- [ADDED]

    @State private var baseInput: String = "USD"                  // 手動入力のfallback // <-- [ADDED]
    @State private var symbolInput: String = "JPY"                // <-- [ADDED]

    var body: some View {
        Group {
            if let b = selection.base, let s = selection.symbol {
                // 選択済み → そのまま詳細チャート
                NavigationStack {
                    RateDetailView(base: b, symbol: s, repository: repository)
                }
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
                            Button("表示") { selection.set(baseInput, symbolInput) }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .navigationTitle("チャート")
            }
        }
    }
}
