//
//  AppConfig.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

enum AppConfig {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SportmonksApiKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }

    static let baseURL = URL(string: "https://api.sportmonks.com/v3/football")!
}
