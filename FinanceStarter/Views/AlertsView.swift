//
//  AlertsView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Views/AlertsView.swift
import SwiftUI
import Charts   // スパークライン用（Charts.framework）

struct AlertsView: View {
    let repository: ExchangeRateRepository

    struct AlertItem: Identifiable {
        let id = UUID()
        let key: String
        let base: String
        let symbol: String
        let upper: Double?
        let lower: Double?
        let upperOnce: Bool
        let lowerOnce: Bool
        let upperFired: Bool
        let lowerFired: Bool
    }

    @State private var items: [AlertItem] = []

    // ==== タブ切替 & 選択通貨ペア（チャートタブへ受け渡し） ====
    @EnvironmentObject private var router: TabRouter
    @EnvironmentObject private var selection: RateSelectionStore

    var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView("登録されたアラートはありません", systemImage: "bell")
            } else {
                ForEach(items) { item in
                    // 行本体（ミニ価格チャート付き）
                    NavigationLink(
                        destination: RateDetailView(base: item.base, symbol: item.symbol, repository: repository)
                    ) {
                        AlertRow(item: item, repository: repository)
                    }
                    // === スワイプで「チャート」へ（選択セット＋タブ切替） ===
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            selection.set(item.base, item.symbol)
                            router.selection = .chart
                        } label: {
                            Label("チャート", systemImage: "waveform.path.ecg")
                        }
                        .tint(.blue)

                        Button(role: .destructive) {
                            remove(key: item.key)
                        } label: { Label("削除", systemImage: "trash") }
                    }
                    // === 長押し（コンテキストメニュー）でも同操作を用意 ===
                    .contextMenu {
                        Button {
                            selection.set(item.base, item.symbol)
                            router.selection = .chart
                        } label: {
                            Label("チャートで表示", systemImage: "waveform.path.ecg")
                        }
                        Button(role: .destructive) {
                            remove(key: item.key)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("アラート")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { load() } label: { Label("更新", systemImage: "arrow.clockwise") }
            }
            ToolbarItem(placement: .topBarLeading) {
                if !items.isEmpty {
                    Button(role: .destructive) { removeAll() } label: {
                        Label("全削除", systemImage: "trash")
                    }
                }
            }
        }
        .onAppear { load() }
    }

    // ---- データ読み込み（UserDefaults のしきい値定義を列挙） ----
    private func load() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("thresh:") }
        var list: [AlertItem] = []
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key),
               let t = try? JSONDecoder().decode(Threshold.self, from: data) {
                // key 形式: "thresh:USD->JPY"
                guard let range = key.range(of: "thresh:") else { continue }
                let pair = String(key[range.upperBound...])
                let comps = pair.split(separator: "->").map(String.init)
                guard comps.count == 2 else { continue }
                list.append(AlertItem(
                    key: key,
                    base: comps[0], symbol: comps[1],
                    upper: t.upper, lower: t.lower,
                    upperOnce: t.upperOnce ?? false,
                    lowerOnce: t.lowerOnce ?? false,
                    upperFired: t.upperFired ?? false,
                    lowerFired: t.lowerFired ?? false
                ))
            }
        }
        items = list.sorted { $0.base < $1.base || ($0.base == $1.base && $0.symbol < $1.symbol) }
    }

    private func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        load()
    }

    private func removeAll() {
        for item in items { UserDefaults.standard.removeObject(forKey: item.key) }
        load()
    }

    private func format(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 6
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }
}

// ================== 行ビュー（ミニ価格チャート付き） ==================
private struct AlertRow: View {
    let item: AlertsView.AlertItem
    let repository: ExchangeRateRepository

    @State private var points: [RatePoint] = []
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        HStack(spacing: 12) {
            // 左：通貨ペアとアラート概要
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.base) → \(item.symbol)")
                    .font(.headline)

                HStack(spacing: 10) {
                    if let up = item.upper {
                        Label("上限 \(format(up))" + (item.upperOnce ? "（一度きり）" : ""),
                              systemImage: item.upperFired ? "bell.fill" : "bell")
                            .font(.caption)
                    }
                    if let lo = item.lower {
                        Label("下限 \(format(lo))" + (item.lowerOnce ? "（一度きり）" : ""),
                              systemImage: item.lowerFired ? "bell.fill" : "bell")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)

                if let error {
                    Text(error).font(.caption2).foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 右：スパークライン（直近7日）
            Group {
                if isLoading {
                    ProgressView().frame(width: 120, height: 32)
                } else if points.isEmpty {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(width: 120, height: 32)
                } else {
                    SparklineView(points: points) // 共有部品（Components/SparklineView.swift）を使用  // <-- [CHANGED]
                }
            }
            .accessibilityHidden(true)
        }
        // 表示時にだけ軽量フェッチ（キャッシュ有効）：
        .task {
            await loadSeries()
        }
    }

    private func loadSeries() async {
        isLoading = true; error = nil
        let cal = Calendar(identifier: .gregorian)
        let end = Date()
        let start = cal.date(byAdding: .day, value: -7, to: end)! // 直近7日だけ取得
        do {
            let pts = try await repository.timeseries(
                base: item.base, symbol: item.symbol,
                start: start, end: end, useCache: true
            )
            if Task.isCancelled { return }
            points = pts
        } catch {
            if Task.isCancelled { return }
            self.error = "データ取得に失敗しました"
            points = []
        }
        isLoading = false
    }

    private func format(_ v: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 6
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }
}

// ==== ここにあったローカル SparklineView は削除しました（重複回避） ====  // <-- [REMOVED]

// VM側と同じ保存構造体（共通化していない場合はここに複製）
private struct Threshold: Codable {
    let upper: Double?
    let lower: Double?
    let upperOnce: Bool?
    let lowerOnce: Bool?
    let upperFired: Bool?
    let lowerFired: Bool?
}
