//
//  FixtureDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation
import SwiftUI

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
    
    let events: [FixtureEvent]?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case startingAt = "starting_at"
        case resultInfo = "result_info"
        case leagueId = "league_id"
        case participants, venue, scores, statistics, lineups
        case events
    }
}

// MARK: - Events (Goals, Cards, Subs)
struct FixtureEvent: Codable, Identifiable {
    let id: Int
    let typeId: Int
    let participantId: Int?
    let playerId: Int?
    let minute: Int?
    let extraMinute: Int?
    
    let type: EventType?
    let player: Player?
    
    enum CodingKeys: String, CodingKey {
        case id
        case typeId = "type_id"
        case participantId = "participant_id"
        case playerId = "player_id"
        case minute
        case extraMinute = "extra_minute"
        case type, player
    }
    
    // MARK: - UI Helpers
    
    var displayTime: String {
        if let extra = extraMinute, extra > 0 {
            return "\(minute ?? 0)+\(extra)'"
        }
        return "\(minute ?? 0)'"
    }
    
    var eventName: String {
        return type?.name ?? ""
    }
    
    var isImportant: Bool {
        let name = eventName.lowercased()
        return name.contains("goal") ||
        name.contains("card") ||
        name.contains("substitution") ||
        name.contains("penalty")
    }
    
    var iconName: String {
        let name = eventName.lowercased()
        if name.contains("goal") || name.contains("penalty") { return "soccerball" }
        if name.contains("card") { return "rectangle.fill" }
        if name.contains("substitution") { return "arrow.triangle.2.circlepath" }
        return "circle.fill"
    }
    
    var iconColor: Color {
        let name = eventName.lowercased()
        if name.contains("yellow") { return .yellow }
        if name.contains("red") { return .red }
        if name.contains("goal") || name.contains("penalty") { return .white }
        return .secondary // Substitutions
    }
}

struct EventType: Codable {
    let name: String?
    let code: String?
}

struct Player: Codable {
    let id: Int
    let name: String
    let imagePath: String?
    enum CodingKeys: String, CodingKey { case id, name = "display_name", imagePath = "image_path" }
}

struct FixtureStatistic: Codable, Identifiable {
    var id: String { "\(typeId)-\(teamId)" }
    let typeId: Int
    let entityId: Int?
    let participantId: Int?
    let type: StatType?
    let data: StatValue?
    var teamId: Int { return entityId ?? participantId ?? 0 }
    enum CodingKeys: String, CodingKey { case typeId = "type_id", entityId = "entity_id", participantId = "participant_id", type, data }
}

struct StatType: Codable { let name: String?; let code: String? }
struct StatValue: Codable {
    let value: Double?
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let d = try? container.decode(Double.self, forKey: .value) { value = d }
        else if let i = try? container.decode(Int.self, forKey: .value) { value = Double(i) }
        else { value = 0.0 }
    }
    enum CodingKeys: String, CodingKey { case value }
}

struct Lineup: Codable, Identifiable {
    let id: Int
    let teamId: Int
    let player: Player?
    let positionId: Int?
    let typeId: Int?
    var positionCategory: String {
        guard let pid = positionId else { return "Substitute" }
        switch pid {
        case 24: return "Goalkeeper"
        case 25, 1, 2, 3, 4, 14, 15, 16, 29, 30, 31, 32: return "Defender"
        case 27, 9, 10, 20, 21, 22, 23, 35, 36, 37, 38, 39, 40, 41, 42: return "Attacker"
        default: return "Midfielder"
        }
    }
    enum CodingKeys: String, CodingKey { case id, teamId = "team_id", player, positionId = "position_id", typeId = "type_id" }
}

extension Fixture {
    var homeTeamId: Int? { participants?.first(where: { $0.meta?.location == "home" })?.id }
    var awayTeamId: Int? { participants?.first(where: { $0.meta?.location == "away" })?.id }
    var currentHomeGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "home" }?.score?.goals }
    var currentAwayGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "away" }?.score?.goals }
    var homeTeamName: String { participants?.first(where: { $0.meta?.location == "home" })?.name ?? "Home" }
    var awayTeamName: String { participants?.first(where: { $0.meta?.location == "away" })?.name ?? "Away" }
}
