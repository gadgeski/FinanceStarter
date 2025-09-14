//
//  BackgroundRefreshManager.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Utils/BackgroundRefreshManager.swift
import Foundation
import BackgroundTasks

enum BackgroundRefreshManager {
    static let taskId = "com.example.FinanceStarter.refresh" // ←あなたのBundle IDに合わせて

    /// アプリ側は (BGAppRefreshTask) -> Void を渡せるが、
    /// BGTaskScheduler の register は (BGTask) -> Void を要求するため、ここでラップする
    static func register(handler: @escaping (BGAppRefreshTask) -> Void) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                // 想定外のタスク型。完了扱いにして早期終了。
                task.setTaskCompleted(success: false)
                return
            }
            handler(refreshTask)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15) // 15分以降
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // 提出失敗は無視またはログ出力に留める
            // print("BG submit error: \(error)")
        }
    }
}
