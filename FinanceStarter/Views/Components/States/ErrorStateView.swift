//
//  ErrorStateView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/States/ErrorStateView.swift
// 役割: エラー表示と再試行導線（7日で試す の選択肢付き）                        // <-- [ADDED]
import SwiftUI

struct ErrorStateView: View {                                                           // <-- [ADDED]
    let message: String
    let onRetry: () -> Void
    let onTry7Days: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ContentUnavailableView(
                "データ取得に失敗",
                systemImage: "wifi.slash",
                description: Text(message)
            )
            HStack {
                Button(action: onRetry) {
                    Label("再試行", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)

                Button(action: onTry7Days) {
                    Label("7日で試す", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
