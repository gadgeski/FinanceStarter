//
//  RateRowView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

// Views/RateRowView.swift
import SwiftUI

struct RateRowView: View {
    let code: String
    let value: Double?                 // <-- [CHANGED] Double -> Double?
    let base: String
    let isWatched: Bool
    let onToggleWatch: () -> Void

    private static let nf: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 6
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Text(code).font(.headline).monospaced()
            Text("/ \(base)").font(.subheadline).foregroundStyle(.secondary)
            Spacer()

            // 値の表示：nil のときはプレースホルダ
            if let v = value {                                                             // <-- [ADDED]
                Text(Self.nf.string(from: NSNumber(value: v)) ?? "\(v)")
                    .font(.body).monospacedDigit()
            } else {
                Text("--").font(.body).foregroundStyle(.secondary)                         // <-- [ADDED]
            }

            Button(action: onToggleWatch) {
                Image(systemName: isWatched ? "star.fill" : "star")
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isWatched ? "ウォッチ解除" : "ウォッチする")
        }
        .contentShape(Rectangle())
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
