//
//  RateRowView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import SwiftUI

struct RateRowView: View {
    let code: String
    let value: Double
    let base: String
    let isWatched: Bool
    let onToggleWatch: () -> Void

    private var formatted: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 6
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(code)
                    .font(.headline)
                Text("1 \(base) → \(code)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(formatted)
                .monospacedDigit()
            Button(action: onToggleWatch) {
                Image(systemName: isWatched ? "star.fill" : "star")
                    .imageScale(.medium)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isWatched ? "ウォッチ解除" : "ウォッチ追加")
        }
        .padding(.vertical, 4)
    }
}

// ===== ここから追加: 行コンポーネント単体の Preview =====
struct RateRowView_Previews: PreviewProvider {           // <-- [ADDED]
    static var previews: some View {                      // <-- [ADDED]
        Group {                                          // <-- [ADDED]
            RateRowView(                                 // <-- [ADDED]
                code: "JPY",                             // <-- [ADDED]
                value: 155.4321,                         // <-- [ADDED]
                base: "USD",                             // <-- [ADDED]
                isWatched: true,                         // <-- [ADDED]
                onToggleWatch: {}                        // <-- [ADDED]
            )
            .previewDisplayName("Watched")               // <-- [ADDED]

            RateRowView(                                 // <-- [ADDED]
                code: "EUR",                             // <-- [ADDED]
                value: 0.92,                             // <-- [ADDED]
                base: "USD",                             // <-- [ADDED]
                isWatched: false,                        // <-- [ADDED]
                onToggleWatch: {}                        // <-- [ADDED]
            )
            .previewDisplayName("Not Watched")           // <-- [ADDED]
        }
        .padding()                                       // <-- [ADDED]
        .previewLayout(.sizeThatFits)                    // <-- [ADDED]
    }                                                    // <-- [ADDED]
}                                                        // <-- [ADDED]
