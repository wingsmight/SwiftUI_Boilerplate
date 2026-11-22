//
//  AppRouter.swift
//

import SwiftfulRouting
import SwiftUI

struct AppRouter: View {
    let container: AppContainer

    var body: some View {
        RouterView { _ in
            RootView(appName: container.configuration.appName)
        }
    }
}

private struct RootView: View {
    let appName: String

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, \(appName)!")
        }
        .padding()
    }
}

#Preview {
    AppRouter(container: AppContainer())
}
