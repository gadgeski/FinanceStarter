//
//  FinanceStarterApp.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/08.
//

import SwiftUI

@main
struct FinanceStarterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: RatesViewModel())
        }
    }
}
