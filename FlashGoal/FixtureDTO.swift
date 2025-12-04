//
//  FixtureDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

struct FixturesResponse: Codable {
    let data: [Fixture]
}

struct Fixture: Codable, Identifiable {
    let id: Int
    let name: String?
    let startingAt: String?
    let resultInfo: String?
    let leagueId: Int
    
    // Includes
    let participants: [Participant]?
    let venue: Venue?
    let scores: [ScoreEntry]?
    let statistics: [FixtureStatistic]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case startingAt = "starting_at"
        case resultInfo = "result_info"
        case leagueId = "league_id"
        case participants
        case venue
        case scores
        case statistics
    }
}

struct FixtureStatistic: Codable {
    let typeId: Int
    let entityId: Int // Team ID
    let data: StatValue?
    
    enum CodingKeys: String, CodingKey {
        case typeId = "type_id"
        case entityId = "entity_id"
        case data
    }
}

struct StatValue: Codable {
    let value: Double?
    let name: String? // "Possession", "Shots on target"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let doubleVal = try? container.decode(Double.self, forKey: .value) {
            value = doubleVal
        } else if let intVal = try? container.decode(Int.self, forKey: .value) {
            value = Double(intVal)
        } else {
            value = 0.0
        }
        name = try? container.decodeIfPresent(String.self, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case value, name
    }
}
