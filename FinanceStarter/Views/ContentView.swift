//
//  ContentView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: RatesViewModel

    init(viewModel: RatesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failed(let message):
                    VStack(spacing: 12) {
                        Text("取得に失敗しました")
                            .font(.headline)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("基準通貨", selection: Binding(
                            get: { viewModel.base },
                            set: { viewModel.setBase($0) }
                        )) {
                            ForEach(viewModel.commonBases, id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                    } label: {
                        Label("基準通貨", systemImage: "dollarsign.arrow.circlepath")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "通貨コードで検索（例: JPY）")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    @ViewBuilder
    private var listView: some View {
        List {
            if !viewModel.watchlistRates.isEmpty {
                Section("ウォッチリスト") {
                    ForEach(viewModel.watchlistRates, id: \.code) { item in
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

            Section("すべて") {
                ForEach(viewModel.otherRates, id: \.code) { item in
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
        .listStyle(.insetGrouped)
    }
}

// ===== ここから変更: プレビューはファクトリを使用 =====
struct ContentView_Previews: PreviewProvider {                         // <-- [CHANGED]
    static var previews: some View {                                   // <-- [CHANGED]
        Group {                                                        // <-- [CHANGED]
            ContentView(viewModel: .preview())                         // <-- [CHANGED]
                .previewDisplayName("Loaded")                          // <-- [CHANGED]

            ContentView(viewModel: .previewLoading())                  // <-- [CHANGED]
                .previewDisplayName("Loading")                         // <-- [CHANGED]

            ContentView(viewModel: .previewError())                    // <-- [CHANGED]
                .previewDisplayName("Error")                           // <-- [CHANGED]
        }                                                              // <-- [CHANGED]
    }                                                                  // <-- [CHANGED]
}                                                                      // <-- [CHANGED]
