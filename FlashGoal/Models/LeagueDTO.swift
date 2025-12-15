//
//  LeagueDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Represents the top-level response for a single league request.
struct LeagueResponse: Codable {
    /// The league details.
    let data: League
}

/// Represents a football competition/league.
struct League: Codable, Identifiable {
    /// The unique identifier of the league.
    let id: Int
    /// The official name of the league.
    let name: String
    /// The URL string to the league's logo.
    let imagePath: String?
    /// The details of the currently active season.
    let currentSeason: SeasonShort?
    
    /// A convenience property to access the current season's ID.
    var currentSeasonId: Int? {
        return currentSeason?.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
        case currentSeason = "currentseason"
    }
}

/// A simplified view of a Season, used when nested within League responses.
struct SeasonShort: Codable {
    /// The unique identifier of the season.
    let id: Int
    /// The name of the season (e.g., "2023/2024").
    let name: String?
}
