//
//  EmptyStateView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/States/EmptyStateView.swift
// 役割: 空データ時のプレースホルダと再試行ボタン                                // <-- [ADDED]
import SwiftUI

struct EmptyStateView: View {                                                           // <-- [ADDED]
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ContentUnavailableView(
                "データがありません",
                systemImage: "chart.xyaxis.line",
                description: Text("期間や通貨コードを変更して再試行してください。")
            )
            Button(action: onRetry) {
                Label("再試行", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
