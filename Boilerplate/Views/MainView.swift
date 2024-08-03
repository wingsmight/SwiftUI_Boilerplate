//
//  MainView.swift
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, boilerplate!")
        }
        .padding()
    }
}

#Preview {
    MainView()
}
