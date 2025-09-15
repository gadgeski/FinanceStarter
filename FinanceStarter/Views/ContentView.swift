//
//  ContentView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

// Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    let repository: ExchangeRateRepository
    @StateObject var viewModel: RatesViewModel
    @Environment(\.tabSelection) private var tabSelection     // RootTabView からのタブ選択 Binding  // <-- [CHANGED]

    // ▼ フォールバック用フラグ：環境が無い場合は Navigation で代替遷移                       // <-- [ADDED]
    @State private var pushToAlerts = false                   // <-- [ADDED]
    @State private var pushToChart = false                    // <-- [ADDED]
    @State private var pushToSettings = false                 // <-- [ADDED]

    init(repository: ExchangeRateRepository,
         viewModel: RatesViewModel) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // ▼ タブ移動の共通口。環境があればタブ切替、無ければフォールバックで PUSH                // <-- [ADDED]
    private func go(_ tab: RootTabView.Tab) {                 // <-- [ADDED]
        if let t = tabSelection {
            t.wrappedValue = tab                              // RootTabView 配下：タブ切替         // <-- [ADDED]
        } else {
            switch tab {                                      // 単体/Preview：代替で PUSH           // <-- [ADDED]
            case .alerts:   pushToAlerts   = true
            case .chart:    pushToChart    = true
            case .settings: pushToSettings = true
            default: break
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { await viewModel.refresh() }     // 初回ロード                         // <-- [CHANGED]

                case .failed(let message):
                    VStack(spacing: 12) {
                        Text("取得に失敗しました").font(.headline)
                        Text(message).font(.caption)
                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            Label("再試行", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded:
                    listView
                }
            }
            .navigationTitle("為替レート (\(viewModel.base))")
            .toolbar { toolbarView }                           // ツールバーは分割して記述              // <-- [CHANGED]
            .searchable(text: $viewModel.searchText, prompt: "通貨コードで検索（例: JPY）")
            .refreshable { await viewModel.refresh() }

            // ▼ フォールバックの遷移先（Root 配下でなくても確実に動く）                       // <-- [ADDED]
            .navigationDestination(isPresented: $pushToAlerts)   { AlertsView(repository: repository) } // <-- [ADDED]
            .navigationDestination(isPresented: $pushToChart)    { ChartTabView(repository: repository) } // <-- [ADDED]
            .navigationDestination(isPresented: $pushToSettings) { SettingsView() }                      // <-- [ADDED]
        }
    }

    // MARK: - Toolbar（基準通貨＋タブ移動メニュー）
    @ToolbarContentBuilder
    private var toolbarView: some ToolbarContent {
        // 先頭：他タブへ移動できるメニュー（アクセシブルな導線）                        // <-- [CHANGED]
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("アラートへ")  { go(.alerts) }          // ← フォールバック対応                // <-- [CHANGED]
                Button("チャートへ")  { go(.chart)  }          // ← フォールバック対応                // <-- [CHANGED]
                Button("設定へ")      { go(.settings) }        // ← フォールバック対応                // <-- [CHANGED]
            } label: {
                Label("移動", systemImage: "list.bullet")
            }
            .accessibilityLabel("移動")                                          // <-- [CHANGED]
            .accessibilityHint("他のタブに移動します")                           // <-- [CHANGED]
        }

        // 右側：基準通貨切替メニュー（型推論コストを下げるため Binding を分割）             // <-- [CHANGED]
        ToolbarItem(placement: .topBarTrailing) {
            let baseBinding = Binding<String>(
                get: { viewModel.base },
                set: { viewModel.setBase($0) }
            )
            Menu {
                Picker("基準通貨", selection: baseBinding) {
                    ForEach(viewModel.commonBases, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                Label("基準通貨", systemImage: "dollarsign.arrow.circlepath")
            }
        }
    }

    // MARK: - List
    @ViewBuilder
    private var listView: some View {
        List {
            if !viewModel.watchlistRates.isEmpty {
                Section("ウォッチリスト") {
                    ForEach(viewModel.watchlistRates, id: \.code) { item in
                        NavigationLink(
                            destination: RateDetailView(
                                base: viewModel.base,
                                symbol: item.code,
                                repository: repository
                            )
                        ) {
                            RateRowView(
                                code: item.code,
                                value: item.value,                     // RateRowView は Double? 受け取りに対応済み
                                base: viewModel.base,
                                isWatched: true,
                                onToggleWatch: { viewModel.toggleWatch(code: item.code) }
                            )
                        }
                        .accessibilityHint("\(item.code) の詳細チャートを開きます")
                    }
                }
            }

            Section("すべて") {
                ForEach(viewModel.otherRates, id: \.code) { item in
                    NavigationLink(
                        destination: RateDetailView(
                            base: viewModel.base,
                            symbol: item.code,
                            repository: repository
                        )
                    ) {
                        RateRowView(
                            code: item.code,
                            value: item.value,
                            base: viewModel.base,
                            isWatched: viewModel.watchlist.contains(item.code),
                            onToggleWatch: { viewModel.toggleWatch(code: item.code) }
                        )
                    }
                    .accessibilityHint("\(item.code) の詳細チャートを開きます")
                }
            }
        }
        .listStyle(.insetGrouped)
        .accessibilitySortPriority(1)                                               // セクション見出しを先に読ませる
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        struct MockRepo: ExchangeRateRepository {
            func timeseries(base: String, symbol: String, start: Date, end: Date, useCache: Bool) async throws -> [RatePoint] {
                let cal = Calendar(identifier: .gregorian)
                var d = start; var i: Double = 0; var pts: [RatePoint] = []
                while d <= end {
                    let v = 150 + 5 * sin(i/6) + Double.random(in: -0.5...0.5)
                    pts.append(RatePoint(date: d, value: v))
                    d = cal.date(byAdding: .day, value: 1, to: d) ?? d.addingTimeInterval(86_400)
                    i += 1
                }
                return pts
            }
        }

        return Group {
            // Preview：環境を注入しない → フォールバックで PUSH が効く                 // <-- [ADDED]
            // フォールバックで PUSH（環境がなくても動くが、ChartTabView が @EnvironmentObject を要求するので注入要）
            ContentView(repository: MockRepo(), viewModel: .preview())
                .environmentObject(RateSelectionStore())  // ← 追加
                .previewDisplayName("Loaded (Fallback PUSH)")

            // Preview：環境を注入する → タブ切替が効く                                  // <-- [ADDED]
            // タブ切替パス（tabSelection も入れて検証）
            ContentView(repository: MockRepo(), viewModel: .preview())
                .environment(\.tabSelection, .constant(.home))
                .environmentObject(RateSelectionStore())             // ← 追加
                .previewDisplayName("Loaded (Tab Switch)")

            ContentView(repository: MockRepo(), viewModel: .previewLoading())
                .previewDisplayName("Loading")

            ContentView(repository: MockRepo(), viewModel: .previewError())
                .previewDisplayName("Error")
        }
    }
}
