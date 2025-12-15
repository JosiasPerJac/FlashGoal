//
//  StandingsDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Represents the top-level response for a standings request.
struct StandingsResponse: Codable {
    /// An array of standing entries (rows in the table).
    let data: [StandingData]
}

/// Represents a single row in a league standings table.
struct StandingData: Codable, Identifiable {
    /// The unique identifier for this standing entry.
    let id: Int
    /// The ID of the team (participant) this entry belongs to.
    let participantId: Int
    /// The ID of the league.
    let leagueId: Int
    /// The ID of the season.
    let seasonId: Int
    /// The team's rank in the table.
    let position: Int
    /// The total accumulated points.
    let points: Int
    /// Detailed breakdown of stats (Won, Lost, Draw, Goals For/Against).
    let details: [StandingDetail]?
    
    /// The participant (team) object associated with this row.
    let participant: Participant?

    enum CodingKeys: String, CodingKey {
        case id
        case participantId = "participant_id"
        case leagueId = "league_id"
        case seasonId = "season_id"
        case position
        case points
        case details
        case participant
    }
}

/// Represents a specific statistical metric within a standing row.
struct StandingDetail: Codable {
    /// The type ID of the statistic (e.g., 129 for 'Played', 130 for 'Won').
    let typeId: Int
    /// The value of the statistic.
    let value: Int
    /// The human-readable description of the stat.
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case typeId = "type_id"
        case value
        case description
    }
}
