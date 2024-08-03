//
//  BoilerplateApp.swift
//

import SwiftfulRouting
import SwiftUI

@main
struct BoilerplateApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                MainView()
            }
        }
    }
}
