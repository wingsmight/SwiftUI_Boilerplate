//
//  BoilerplateApp.swift
//

import SwiftUI

@main
struct BoilerplateApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            AppRouter(container: container)
        }
    }
}
