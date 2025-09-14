//
//  HelpView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/HelpView.swift  // <-- [ADDED]
import SwiftUI

struct HelpView: View {                            // <-- [ADDED]
    var body: some View {
        List {
            Section("クイックスタート") {
                LabeledContent("アラートを設定") {
                    Text("詳細画面の下部で上限/下限を入力し「保存」。一度きりモードで再アーム制御も可能。")
                }
                LabeledContent("指標を調整") {
                    Text("SMA/BB/RSIの期間をステッパーで変更→「再計算」。")
                }
                LabeledContent("CSVエクスポート") {
                    Text("右上の共有ボタンから時系列データをCSVで保存。")
                }
            }

            Section("用語集") {
                LabeledContent("SMA") { Text("一定期間の平均値。トレンドの向きやクロスが目安。") }
                LabeledContent("ボリンジャーバンド") { Text("平均±k×標準偏差。帯の広がりはボラティリティ。") }
                LabeledContent("RSI") { Text("0〜100。30付近は売られ過ぎ、70付近は買われ過ぎの目安。") }
                LabeledContent("一度きりモード") { Text("閾値で通知後、反対側へ戻るまで自動で再アームしない設定。") }
            }

            Section("困ったときは") {
                Text("データが表示されない：ネットワーク、基準/通貨コード、日付範囲を確認。プレビューならMockが表示されます。")
                Text("通知が来ない：初回に通知許可が必要。設定アプリ→通知→本アプリを確認。")
            }
        }
        .navigationTitle("ヘルプ・用語集")
    }
}

#Preview {
    NavigationStack { HelpView() }
}
