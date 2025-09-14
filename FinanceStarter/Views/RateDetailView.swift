//
//  RateDetailView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Views/RateDetailView.swift
// Views/RateDetailView.swift  // <-- [REPLACED]
import SwiftUI

struct RateDetailView: View {
    let base: String
    let symbol: String
    @StateObject private var viewModel: AdvancedRateDetailViewModel

    // ✅ デフォルト引数を削除して repository を必須に
    init(base: String, symbol: String, repository: ExchangeRateRepository) {         // <-- [CHANGED]
        self.base = base
        self.symbol = symbol
        _viewModel = StateObject(wrappedValue: AdvancedRateDetailViewModel(base: base, symbol: symbol, repository: repository))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                rangePicker
                chartSection
                indicatorSection
                thresholdsSection
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("\(base) / \(symbol)")
        .task { await viewModel.refresh() }                                           // 初回ロード
        .refreshable { await viewModel.refresh() }
    }

    // 範囲切替
    private var rangePicker: some View {                                              // <-- [ADDED]
        Picker("範囲", selection: $viewModel.selectedRange) {
            ForEach(AdvancedRateDetailViewModel.Range.allCases) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // チャート（ここはあなたのチャート実装に置換OK）
    private var chartSection: some View {                                             // <-- [ADDED]
        VStack(alignment: .leading, spacing: 8) {
            Text("価格推移").font(.headline).padding(.horizontal)
            // 例：簡易スパークラインの流用
            SparklineView(points: viewModel.points)
                .frame(height: 120)
                .padding(.horizontal)
        }
    }

    // 指標表示（簡略）
    private var indicatorSection: some View {                                         // <-- [ADDED]
        VStack(alignment: .leading, spacing: 8) {
            Text("テクニカル").font(.headline).padding(.horizontal)
            HStack {
                VStack(alignment: .leading) {
                    Text("SMA(\(viewModel.smaShortWindow)) 点数: \(viewModel.smaShort.count)")
                    Text("SMA(\(viewModel.smaLongWindow)) 点数: \(viewModel.smaLong.count)")
                }
                Spacer(minLength: 16)
                VStack(alignment: .leading) {
                    Text("BB(\(viewModel.bbWindow), k=\(String(format: "%.1f", viewModel.bbK)))")
                    Text("RSI(\(viewModel.rsiPeriod)) 点数: \(viewModel.rsi.count)")
                }
            }
            .font(.caption)
            .padding(.horizontal)
        }
    }

    // しきい値設定（要: あなたの UI に合わせて改良可）
    private var thresholdsSection: some View {                                        // <-- [ADDED]
        VStack(alignment: .leading, spacing: 8) {
            Text("アラート").font(.headline).padding(.horizontal)
            HStack {
                Text("上限: \(viewModel.upperThreshold.map { viewModel.format($0) } ?? "--")")
                Text("下限: \(viewModel.lowerThreshold.map { viewModel.format($0) } ?? "--")")
            }
            .font(.caption)
            .padding(.horizontal)
        }
    }
}
