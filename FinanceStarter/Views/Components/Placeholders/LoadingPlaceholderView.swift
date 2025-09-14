//
//  LoadingPlaceholderView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/Placeholders/LoadingPlaceholderView.swift
// 役割: ローディング中のプレースホルダ（スケルトン）                           // <-- [ADDED]
import SwiftUI

struct LoadingPlaceholderView: View {                                                   // <-- [ADDED]
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.quaternary, lineWidth: 1)
            .frame(height: 260)
            .overlay {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("読み込み中…").foregroundStyle(.secondary)
                }
            }
            .redacted(reason: .placeholder)
    }
}
