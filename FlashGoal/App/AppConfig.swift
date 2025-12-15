//
//  AppConfig.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Manages application-wide configuration settings and environment variables.
///
/// This enumeration provides a centralized accessor for critical configuration data,
/// such as API keys and base URLs, ensuring type safety and consistency across the networking layer.
enum AppConfig {
    /// Retrieves the Sportmonks API Key from the application's `Info.plist`.
    ///
    /// This property attempts to look up the value associated with the key `SportmonksApiKey`.
    ///
    /// - Warning: This property will cause a fatal error if the `SportmonksApiKey` is missing from the `Info.plist`.
    ///            Ensure strict configuration management before deploying.
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SportmonksApiKey") as? String else {
            fatalError("API Key not found in Info.plist")
        }
        return key
    }

    /// The base URL for the Sportmonks V3 Football API.
    ///
    /// This URL is used as the root for all network requests constructed by the `SportmonksClient`.
    static let baseURL = URL(string: "https://api.sportmonks.com/v3/football")!
}
