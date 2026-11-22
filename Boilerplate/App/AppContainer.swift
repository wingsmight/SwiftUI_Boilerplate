//
//  AppContainer.swift
//

import Foundation

struct AppContainer {
    let configuration: AppConfiguration

    init(configuration: AppConfiguration = .current) {
        self.configuration = configuration
    }
}
