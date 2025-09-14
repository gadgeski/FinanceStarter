//
//  TechnicalIndicators.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Utils/TechnicalIndicators.swift  // <-- [ADDED]
import Foundation

enum Indicators {
    static func SMA(points: [RatePoint], window: Int) -> [RatePoint] {
        guard window > 1, points.count >= window else { return [] }
        var result: [RatePoint] = []; var sum: Double = 0; var q: [RatePoint] = []
        for p in points {
            q.append(p); sum += p.value
            if q.count > window { sum -= q.removeFirst().value }
            if q.count == window { result.append(RatePoint(date: p.date, value: sum / Double(window))) }
        }
        return result
    }

    static func Bollinger(points: [RatePoint], window: Int = 20, k: Double = 2.0) -> (middle: [RatePoint], upper: [RatePoint], lower: [RatePoint]) {
        let sma = SMA(points: points, window: window)
        guard !sma.isEmpty else { return ([],[],[]) }
        var upp: [RatePoint] = []; var low: [RatePoint] = []
        for (idx, m) in sma.enumerated() {
            let endIndex = idx + window
            let slice = Array(points[(endIndex - window)..<endIndex])
            let avg = m.value
            let varSum = slice.reduce(0.0) { $0 + pow($1.value - avg, 2) }
            let std = sqrt(varSum / Double(window))
            upp.append(RatePoint(date: m.date, value: avg + k * std))
            low.append(RatePoint(date: m.date, value: avg - k * std))
        }
        return (sma, upp, low)
    }

    static func RSI(points: [RatePoint], period: Int = 14) -> [RatePoint] {
        guard points.count > period else { return [] }
        var rsis: [RatePoint] = []
        var gains: [Double] = []; var losses: [Double] = []
        for i in 1..<points.count {
            let diff = points[i].value - points[i-1].value
            gains.append(max(diff, 0)); losses.append(max(-diff, 0))
        }
        var avgGain = gains.prefix(period).reduce(0,+) / Double(period)
        var avgLoss = losses.prefix(period).reduce(0,+) / Double(period)
        for i in period..<(points.count-1) {
            let g = gains[i]; let l = losses[i]
            avgGain = (avgGain * Double(period - 1) + g) / Double(period)
            avgLoss = (avgLoss * Double(period - 1) + l) / Double(period)
            let rs = avgLoss == 0 ? Double.greatestFiniteMagnitude : avgGain / avgLoss
            let rsi = 100 - (100 / (1 + rs))
            rsis.append(RatePoint(date: points[i+1].date, value: rsi))
        }
        return rsis
    }
}
