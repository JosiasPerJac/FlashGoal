//
//  StandingsDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

struct StandingsResponse: Codable {
    let data: [StandingData]
}

struct StandingData: Codable, Identifiable {
    let id: Int
    let participantId: Int
    let leagueId: Int
    let seasonId: Int
    let position: Int
    let points: Int
    let details: [StandingDetail]?
    
    // Include: participant
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

// "Won", "Lost", "Goals", etc.
struct StandingDetail: Codable {
    let typeId: Int
    let value: Int
    let description: String? // "Wins", "Lost", "Goals", etc.
    
    enum CodingKeys: String, CodingKey {
        case typeId = "type_id"
        case value
        case description
    }
}
