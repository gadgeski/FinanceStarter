//
//  ThresholdEditorView.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/12.
//

// Views/Components/Controls/ThresholdEditorView.swift
// 役割: アラート上限/下限・一度きりフラグの編集、保存/リセット                 // <-- [ADDED]
import SwiftUI

struct ThresholdEditorView: View {                                                      // <-- [ADDED]
    @Binding var upperText: String
    @Binding var lowerText: String
    @Binding var upperOnce: Bool
    @Binding var lowerOnce: Bool
    let onSave: (_ upper: Double?, _ lower: Double?, _ upperOnce: Bool, _ lowerOnce: Bool) -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("価格アラート（ローカル通知）").font(.headline).padding(.horizontal)

            HStack {
                VStack(alignment: .leading) {
                    Text("上限").font(.caption)
                    TextField("例) 160.0", text: $upperText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                    Toggle("一度きり", isOn: $upperOnce)
                }
                VStack(alignment: .leading) {
                    Text("下限").font(.caption)
                    TextField("例) 150.0", text: $lowerText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 160)
                    Toggle("一度きり", isOn: $lowerOnce)
                }
                Spacer()
                VStack {
                    Button("保存") {
                        onSave(Double(upperText), Double(lowerText), upperOnce, lowerOnce)
                    }
                    .buttonStyle(.borderedProminent)
                    Button("リセット", action: onReset)
                        .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            Text("※ いったん発火した“一度きり”は、反対側へ戻るか「リセット」で再アーム。")
                .font(.footnote).foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.top, 8)
    }
}
