//
//  PriceChartView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/Charts/PriceChartView.swift
// 役割: 価格・SMA・BBの描画とアクセシビリティ要約、RSIトグルの表示          // <-- [ADDED]
import SwiftUI
import Charts

struct PriceChartView: View {                                                            // <-- [ADDED]
    let points: [RatePoint]
    let smaShort: [RatePoint]
    let smaLong: [RatePoint]
    let bbUpper: [RatePoint]
    let bbLower: [RatePoint]
    let smaShortWindow: Int
    let smaLongWindow: Int
    let showIndicators: Bool
    @Binding var showRSI: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("価格推移").font(.headline)
                Spacer()
                Toggle("RSI", isOn: $showRSI).toggleStyle(.switch).labelsHidden()
            }
            .padding(.horizontal)

            Chart {
                // 実値
                ForEach(points) { p in
                    LineMark(x: .value("日付", p.date), y: .value("レート", p.value))
                        .interpolationMethod(.monotone)
                }

                if showIndicators {
                    // ボリンジャーバンド帯（上限/下限の塗り）
                    ForEach(zip(bbLower, bbUpper).map { ($0.0, $0.1) }, id: \.0.id) { low, up in
                        AreaMark(
                            x: .value("日付", low.date),
                            yStart: .value("下限", low.value),
                            yEnd: .value("上限", up.value)
                        )
                        .opacity(0.15)
                    }
                    // BB上下
                    ForEach(bbUpper) { p in
                        LineMark(x: .value("日付", p.date), y: .value("BB上", p.value))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    ForEach(bbLower) { p in
                        LineMark(x: .value("日付", p.date), y: .value("BB下", p.value))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                    }
                    // SMA
                    ForEach(smaShort)  { p in
                        LineMark(x: .value("日付", p.date), y: .value("SMA\(smaShortWindow)", p.value))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4,4]))
                    }
                    ForEach(smaLong) { p in
                        LineMark(x: .value("日付", p.date), y: .value("SMA\(smaLongWindow)", p.value))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2,3]))
                    }
                }
            }
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 6)) }
            .chartYAxis { AxisMarks(values: .automatic(desiredCount: 5)) }
            .frame(height: 260)
            .padding(.horizontal)
            // 超軽量デバッグ: 取得点数
            .overlay(alignment: .topTrailing) {
                Text("\(points.count) pts")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .padding(8)
            }
            // アクセシビリティ: 要約テキスト
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("価格推移チャート")
            .accessibilityValue(chartSummaryText())
            .accessibilityHint("二本指でスクロールすると他の要素に移動します")
        }
    }

    // a11y要約
    private func chartSummaryText() -> String {
        guard let last = points.last?.value else { return "データなし" }
        let vals = points.map(\.value)
        if let min = vals.min(), let max = vals.max() {
            return "最新 \(format(last))、最高 \(format(max))、最低 \(format(min))。"
        }
        return "最新 \(format(last))。"
    }

    private func format(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 6
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }
}
