//
//  FixtureDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

struct FixturesResponse: Codable {
    let data: [Fixture]?
    let message: String?
}

struct Fixture: Codable, Identifiable {
    let id: Int
    let name: String?
    let startingAt: String?
    let resultInfo: String?
    let leagueId: Int
    
    let participants: [Participant]?
    let venue: Venue?
    let scores: [ScoreEntry]?
    let statistics: [FixtureStatistic]?
    let lineups: [Lineup]?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case startingAt = "starting_at"
        case resultInfo = "result_info"
        case leagueId = "league_id"
        case participants, venue, scores, statistics, lineups
    }
}

// MARK: - Team Statistics
struct FixtureStatistic: Codable, Identifiable {
    var id: String { "\(typeId)-\(teamId)" }
    let typeId: Int
    let entityId: Int?
    let participantId: Int?
    let type: StatType?
    let data: StatValue?
    
    var teamId: Int { return entityId ?? participantId ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case typeId = "type_id"
        case entityId = "entity_id"
        case participantId = "participant_id"
        case type, data
    }
}

struct StatType: Codable {
    let name: String?
    let code: String?
}

struct StatValue: Codable {
    let value: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let doubleVal = try? container.decode(Double.self, forKey: .value) {
            value = doubleVal
        } else if let intVal = try? container.decode(Int.self, forKey: .value) {
            value = Double(intVal)
        } else {
            value = 0.0
        }
    }
    enum CodingKeys: String, CodingKey { case value }
}

// MARK: - Lineups
struct Lineup: Codable, Identifiable {
    let id: Int
    let teamId: Int
    let player: Player?
    let positionId: Int?
    let typeId: Int?
    
    var positionCategory: String {
        guard let pid = positionId else { return "Substitute" }
        
        switch pid {
        case 24:
            return "Goalkeeper"
            
        case 25, 1, 2, 3, 4, 14, 15, 16, 29, 30, 31, 32:
            return "Defender"
            
        case 27, 9, 10, 20, 21, 22, 23, 35, 36, 37, 38, 39, 40, 41, 42:
            return "Attacker"
            
        case 26, 5, 6, 7, 8, 11, 12, 13, 18, 19, 33, 34:
            return "Midfielder"
            
        default:
            return "Midfielder"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case player
        case positionId = "position_id"
        case typeId = "type_id"
    }
}

struct Player: Codable {
    let id: Int
    let name: String
    let imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "display_name"
        case imagePath = "image_path"
    }
}

// MARK: - Extensions
extension Fixture {
    var homeTeamId: Int? { participants?.first(where: { $0.meta?.location == "home" })?.id }
    var awayTeamId: Int? { participants?.first(where: { $0.meta?.location == "away" })?.id }
    
    var currentHomeGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "home" }?.score?.goals }
    var currentAwayGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "away" }?.score?.goals }
    
    var homeTeamName: String { participants?.first(where: { $0.meta?.location == "home" })?.name ?? "Home" }
    var awayTeamName: String { participants?.first(where: { $0.meta?.location == "away" })?.name ?? "Away" }
}
