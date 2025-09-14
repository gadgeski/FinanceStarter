//
//  RatePoint.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/13.
//

// Models/RatePoint.swift
import Foundation

/// 為替レートの時系列1点を表すモデル。
/// - 備考: CacheStore で [RatePoint] を JSON エンコード/デコードするため Codable を付与。
struct RatePoint: Identifiable, Codable { // <-- [CHANGED] Codable 準拠を追加（キャッシュ保存/復元のため）
    /// 一意性は日時で表現（同一日時は同一点とみなす）
    var id: Date { date }

    /// 計測日時
    let date: Date

    /// レート値
    let value: Double

    /// 明示イニシャライザ（Synthesizedでも可。可読性のため定義）
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}
