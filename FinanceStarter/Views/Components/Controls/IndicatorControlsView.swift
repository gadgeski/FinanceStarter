//
//  IndicatorControlsView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/Controls/IndicatorControlsView.swift
// 役割: SMA/BB/RSI のパラメータ操作と再計算トリガ                              // <-- [ADDED]
import SwiftUI

struct IndicatorControlsView: View {                                                    // <-- [ADDED]
    @Binding var smaShortWindow: Int
    @Binding var smaLongWindow: Int
    @Binding var bbWindow: Int
    @Binding var bbK: Double
    @Binding var rsiPeriod: Int
    let onRecompute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("指標パラメータ").font(.headline).padding(.horizontal)

            HStack {
                Stepper("SMA短期: \(smaShortWindow)", value: $smaShortWindow, in: 2...30)
                Stepper("SMA長期: \(smaLongWindow)", value: $smaLongWindow, in: 5...60)
            }.padding(.horizontal)

            HStack {
                Stepper("BB期間: \(bbWindow)", value: $bbWindow, in: 10...60)
                // NG: Stepper("BB k: \(String(format: \"%.1f\", bbK))", value: $bbK, in: 1.0...3.0, step: 0.5)
                Stepper("BB k: \(String(format: "%.1f", bbK))",               // <-- [CHANGED]
                        value: $bbK,                                          // <-- [CHANGED]
                        in: 1.0...3.0,                                        // <-- [CHANGED]
                        step: 0.5)                                            // <-- [CHANGED]
            }.padding(.horizontal)

            HStack {
                Stepper("RSI期間: \(rsiPeriod)", value: $rsiPeriod, in: 5...30)
                Spacer()
                Button("再計算", action: onRecompute)
                    .buttonStyle(.borderedProminent)
            }.padding(.horizontal)
        }
    }
}
