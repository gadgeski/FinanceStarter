//
//  RSIChartView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/Charts/RSIChartView.swift
// 役割: RSIの描画とアクセシビリティ要約                                        // <-- [ADDED]
import SwiftUI
import Charts

struct RSIChartView: View {                                                             // <-- [ADDED]
    let rsi: [RatePoint]
    let period: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RSI(\(period))").font(.headline).padding(.horizontal)
            Chart {
                ForEach(rsi) { p in
                    LineMark(x: .value("日付", p.date), y: .value("RSI", p.value))
                        .interpolationMethod(.monotone)
                }
                RuleMark(y: .value("70", 70)).lineStyle(StrokeStyle(lineWidth: 1, dash: [3,3]))
                RuleMark(y: .value("30", 30)).lineStyle(StrokeStyle(lineWidth: 1, dash: [3,3]))
            }
            .chartYScale(domain: 0...100)
            .frame(height: 160)
            .padding(.horizontal)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("RSIチャート")
            .accessibilityValue(rsiSummaryText())
        }
    }

    private func rsiSummaryText() -> String {
        guard let last = rsi.last?.value else { return "データなし" }
        let zone: String
        switch last {
        case ..<30: zone = "売られ過ぎ気味"
        case 70...: zone = "買われ過ぎ気味"
        default: zone = "中立"
        }
        return "最新 \(Int(last))、\(zone)。"
    }
}
