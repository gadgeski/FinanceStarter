//
//  SettingsView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @State private var scheduled = false
    @State private var lastBG: Date? = BackgroundStatus.lastSuccess()

    var body: some View {
        Form {
            Section("通知") {
                Button("通知を許可") {
                    NotificationManager.requestAuthorization()
                }
            }

            Section("バックグラウンド更新") {
                Toggle("自動でデータを更新", isOn: $scheduled)
                    .onChange(of: scheduled, initial: false) { _, newValue in
                        if newValue { BackgroundRefreshManager.schedule() }
                    }

                HStack {
                    Text("最終更新")
                    Spacer()
                    Text(format(lastBG) ?? "未実行")
                        .foregroundStyle(.secondary)
                }

                Button("状態を更新") { lastBG = BackgroundStatus.lastSuccess() }
            }

            Section("ヘルプ") {                                     // <-- [ADDED]
                NavigationLink { HelpView() } label: {
                    Label("ヘルプ・用語集", systemImage: "questionmark.circle")
                }
                NavigationLink {
                    OnboardingView { }                              // 再表示も可能  // <-- [ADDED]
                } label: {
                    Label("オンボーディングをもう一度見る", systemImage: "play.rectangle")
                }
            }

            Section("情報") {
                Text("バージョン 0.1.0")
                Text("ビルド \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("設定")
        .onAppear { lastBG = BackgroundStatus.lastSuccess() }
    }

    private func format(_ date: Date?) -> String? {
        guard let date else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd HH:mm"
        return f.string(from: date)
    }
}
