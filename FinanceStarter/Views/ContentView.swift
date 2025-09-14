//
//  ContentView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

// Views/ContentView.swift  // <-- [CHANGED]
// Views/ContentView.swift  // <-- [UPDATED]
import SwiftUI

struct ContentView: View {
    let repository: ExchangeRateRepository
    @StateObject var viewModel: RatesViewModel

    init(repository: ExchangeRateRepository, viewModel: RatesViewModel) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {                                    // <-- [CHANGED] （重い式分割の前提）
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { await viewModel.refresh() }  // 初回ロード                       // <-- [ADDED]

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
            .toolbar { toolbarView }                         // <-- [CHANGED] Toolbar を分割
            .searchable(text: $viewModel.searchText, prompt: "通貨コードで検索（例: JPY）")
            .refreshable { await viewModel.refresh() }
        }
    }

    // Toolbar（基準通貨切替）を分割してコンパイラの負担を軽くする
    @ToolbarContentBuilder
    private var toolbarView: some ToolbarContent {           // <-- [ADDED]
        ToolbarItem(placement: .topBarTrailing) {
            let baseBinding = Binding<String>(                // <-- [ADDED] Binding を独立
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
                                value: item.value,
                                base: viewModel.base,
                                isWatched: true,
                                onToggleWatch: { viewModel.toggleWatch(code: item.code) }
                            )
                        }
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
                }
            }
        }
        .listStyle(.insetGrouped)
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
            ContentView(repository: MockRepo(), viewModel: .preview())
                .previewDisplayName("Loaded")
            ContentView(repository: MockRepo(), viewModel: .previewLoading())
                .previewDisplayName("Loading")
            ContentView(repository: MockRepo(), viewModel: .previewError())
                .previewDisplayName("Error")
        }
    }
}
