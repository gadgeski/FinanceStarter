//
//  OnboardingView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/OnboardingView.swift  // <-- [ADDED]
import SwiftUI

struct OnboardingView: View {                         // <-- [ADDED]
    var onFinish: () -> Void

    @State private var index = 0
    @State private var notifEnabled = false
    @State private var bgEnabled = true

    var body: some View {
        ZStack {
            TabView(selection: $index) {
                pageWelcome.tag(0)
                pagePermissions.tag(1)
                pageIndicators.tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack {
                HStack {
                    Button("スキップ") { onFinish() }
                        .padding(16)
                    Spacer()
                }
                Spacer()
                HStack {
                    Button(action: { withAnimation { index = max(0, index - 1) } }) {
                        Label("戻る", systemImage: "chevron.left")
                    }
                    .disabled(index == 0)

                    Spacer()

                    Button(action: {
                        withAnimation { index = min(2, index + 1) }
                        if index == 2 { onFinish() }
                    }) {
                        Label(index < 2 ? "次へ" : "はじめる", systemImage: index < 2 ? "chevron.right" : "checkmark.circle")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }

    private var pageWelcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 64))
                .padding(.top, 40)
            Text("ようこそ")
                .font(.largeTitle.bold())
            Text("価格推移の可視化、テクニカル指標、アラート、CSVエクスポートまで。\n最短手順で判断できるよう設計しました。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
    }

    private var pagePermissions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("通知と自動更新").font(.title2.bold()).padding(.top, 24)

            Toggle(isOn: $notifEnabled) {
                VStack(alignment: .leading) {
                    Text("価格アラートの通知を受け取る")
                    Text("しきい値に達したときに通知します。").font(.caption).foregroundStyle(.secondary)
                }
            }
            .onChange(of: notifEnabled) { _, newValue in
                if newValue { NotificationManager.requestAuthorization() } // 許諾リクエスト
            }

            Toggle(isOn: $bgEnabled) {
                VStack(alignment: .leading) {
                    Text("バックグラウンドでデータを更新")
                    Text("アプリを開いていない間も最新をチェックします。").font(.caption).foregroundStyle(.secondary)
                }
            }
            .onChange(of: bgEnabled) { _, newValue in
                if newValue { BackgroundRefreshManager.schedule() }
            }

            Spacer()
            Text("※ 許可設定はあとから「設定」→「通知」で変更できます。")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var pageIndicators: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("指標の使い方").font(.title2.bold()).padding(.top, 24)
                Group {
                    Text("SMA（単純移動平均）")
                        .font(.headline)
                    Text("一定期間の平均値。短期と長期のクロスでトレンドの強弱を把握。")
                        .foregroundStyle(.secondary)
                    Text("ボリンジャーバンド")
                        .font(.headline).padding(.top, 8)
                    Text("平均値±k×標準偏差。帯の拡縮でボラティリティを可視化。")
                        .foregroundStyle(.secondary)
                    Text("RSI")
                        .font(.headline).padding(.top, 8)
                    Text("0〜100で買われ過ぎ／売られ過ぎの目安（一般に30/70）。")
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing)

                NavigationLink(destination: HelpView()) {
                    Label("用語集とヘルプを見る", systemImage: "questionmark.circle")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)

                Spacer(minLength: 24)
            }
            .padding(.horizontal)
        }
    }
}

// プレビュー
#Preview("Onboarding") {
    OnboardingView { }
}
