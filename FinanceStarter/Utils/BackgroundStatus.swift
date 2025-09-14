//
//  BackgroundStatus.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Utils/BackgroundStatus.swift  // <-- [ADDED]
import Foundation

enum BackgroundStatus {
    private static let lastSuccessKey = "bg.lastSuccessAt"

    static func markSuccess(_ date: Date = Date()) {
        UserDefaults.standard.set(date, forKey: lastSuccessKey)
    }

    static func lastSuccess() -> Date? {
        UserDefaults.standard.object(forKey: lastSuccessKey) as? Date
    }
}
