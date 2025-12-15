//
//  Constants.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// A collection of static constants defining the scope of leagues supported by the application.
///
/// This enumeration serves as a namespace for league-specific identifiers used throughout the app
/// to filter API responses and manage navigation tabs.
enum LeagueConstants {
    /// The unique identifier for the Scottish Premiership within the Sportmonks API.
    ///
    /// - Note: ID `501` corresponds to the top-flight football league in Scotland.
    static let scottishPremiershipId = 501
    
    /// The unique identifier for the Danish Superliga within the Sportmonks API.
    ///
    /// - Note: ID `271` corresponds to the top-flight football league in Denmark.
    static let danishSuperligaId = 271
    
    /// An array of all league IDs currently supported by the application.
    ///
    /// This collection is used primarily by the `FootballRepository` to filter incoming fixtures
    /// and ensures the app only displays data relevant to these specific competitions.
    static let supportedLeagues = [scottishPremiershipId, danishSuperligaId]
}
