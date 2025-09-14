//
//  TabRouter.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/11.
//

// Utils/TabRouter.swift
import Foundation
import SwiftUI

final class TabRouter: ObservableObject {                 // <-- [ADDED]
    enum Tab: Hashable { case market, alerts, chart, settings }  // <-- [ADDED]
    @Published var selection: Tab = .market               // <-- [ADDED]
}
