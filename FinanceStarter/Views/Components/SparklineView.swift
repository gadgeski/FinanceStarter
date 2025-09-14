//
//  SparklineView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/Components/SparklineView.swift
// 小さな折れ線グラフ（軸非表示・省スペース）
import Foundation
import SwiftUI          // <-- [CHANGED] 念のため順序を明示（なくてもOKだが可読性のため）
import Charts

#if canImport(SwiftUI) && canImport(Charts)      // <-- [CHANGED] 環境ガード
struct SparklineView: SwiftUI.View {             // <-- [CHANGED] モジュール完全修飾
    let points: [RatePoint]

    // Yスケールに少し余白
    private var yDomain: ClosedRange<Double> {                 // ← Optional をやめる
        // points が空のときは body 側の if で Chart を描かないので、ここは呼ばれても問題なし
        let minV = points.map(\.value).min() ?? 0
        let maxV = points.map(\.value).max() ?? 1
        let pad = max((maxV - minV) * 0.1, 0.001)
        return (minV - pad)...(maxV + pad)
    }

    var body: some SwiftUI.View {                // <-- [CHANGED] 完全修飾
        Group {
            if points.isEmpty {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.quaternary)
                    .frame(width: 120, height: 32)
                    .overlay(Text("--").font(.caption2).foregroundStyle(.secondary))
                    .accessibilityHidden(true)
            } else {
                Chart {
                    ForEach(points) { p in
                        LineMark(x: .value("日付", p.date), y: .value("値", p.value))
                            .interpolationMethod(.monotone)
                    }
                    if let last = points.last {
                        PointMark(x: .value("日付", last.date), y: .value("値", last.value))
                    }
                }
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .chartYScale(domain: yDomain)
                .chartPlotStyle { $0.padding(.zero) }
                .frame(width: 120, height: 32)
                .accessibilityHidden(true)
            }
        }
    }
}
#else
// SwiftUI/Charts が import できない環境向けのダミー（ビルドを通すため）
struct SparklineView: SwiftUI.View {
    let points: [RatePoint]
    var body: some SwiftUI.View {
        EmptyView()
    }
}
#endif
