//
//  FixtureDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation
import SwiftUI

/// Represents the top-level API response when fetching fixtures.
struct FixturesResponse: Codable {
    /// The collection of fixture data returned by the API.
    let data: [Fixture]?
    /// An optional status or error message from the API.
    let message: String?
}

/// Represents a single football match (fixture).
///
/// This model contains comprehensive data about a match, including its scheduling,
/// participating teams, venue, live scores, statistics, and timeline events.
struct Fixture: Codable, Identifiable {
    /// The unique identifier for the fixture.
    let id: Int
    /// The descriptive name of the match (e.g., "HomeTeam vs AwayTeam").
    let name: String?
    /// The ISO8601 string representing the match start time.
    let startingAt: String?
    /// A textual description of the match state (e.g., "Ended", "Live", "1st Half").
    let resultInfo: String?
    /// The ID of the league this fixture belongs to.
    let leagueId: Int
    
    /// The teams (Home/Away) participating in the match.
    let participants: [Participant]?
    /// The stadium or venue where the match is played.
    let venue: Venue?
    /// A list of score entries (e.g., current score, half-time score).
    let scores: [ScoreEntry]?
    /// Match-level statistics (e.g., Possession, Shots).
    let statistics: [FixtureStatistic]?
    /// The player lineups for both teams.
    let lineups: [Lineup]?
    
    /// A chronological list of match events (goals, cards, substitutions).
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

/// Represents a specific event occurring during a match, such as a Goal, Card, or Substitution.
struct FixtureEvent: Codable, Identifiable {
    /// The unique identifier of the event.
    let id: Int
    /// The ID representing the type of event (mapped internally by the API).
    let typeId: Int
    /// The ID of the participant (team) associated with the event.
    let participantId: Int?
    /// The ID of the player involved in the event.
    let playerId: Int?
    /// The minute mark when the event occurred.
    let minute: Int?
    /// Any additional minutes played during stoppage time.
    let extraMinute: Int?
    
    /// Detailed information about the event type (e.g., name, code).
    let type: EventType?
    /// The player object associated with this event.
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
    
    /// A formatted string representing the time of the event.
    ///
    /// - Returns: Format "90+3'" for stoppage time or "45'" for regular time.
    var displayTime: String {
        if let extra = extraMinute, extra > 0 {
            return "\(minute ?? 0)+\(extra)'"
        }
        return "\(minute ?? 0)'"
    }
    
    /// The descriptive name of the event type (e.g., "Goal", "Yellow Card").
    var eventName: String {
        return type?.name ?? ""
    }
    
    /// Determines if the event is significant enough to be shown in the main timeline summary.
    ///
    /// - Returns: `true` if the event is a Goal, Card, Substitution, or Penalty.
    var isImportant: Bool {
        let name = eventName.lowercased()
        return name.contains("goal") ||
        name.contains("card") ||
        name.contains("substitution") ||
        name.contains("penalty")
    }
    
    /// Returns the SF Symbol system name appropriate for the event type.
    var iconName: String {
        let name = eventName.lowercased()
        if name.contains("goal") || name.contains("penalty") { return "soccerball" }
        if name.contains("card") { return "rectangle.fill" }
        if name.contains("substitution") { return "arrow.triangle.2.circlepath" }
        return "circle.fill"
    }
    
    /// Returns the UI color associated with the event type.
    ///
    /// - Returns: `.yellow` for yellow cards, `.red` for red cards, `.white` for goals.
    var iconColor: Color {
        let name = eventName.lowercased()
        if name.contains("yellow") { return .yellow }
        if name.contains("red") { return .red }
        if name.contains("goal") || name.contains("penalty") { return .white }
        return .secondary // Substitutions
    }
}

/// Detailed classification of an event.
struct EventType: Codable {
    /// The name of the event type.
    let name: String?
    /// The code associated with the event type.
    let code: String?
}

/// A simplified player representation used within events and lineups.
struct Player: Codable {
    /// The unique player ID.
    let id: Int
    /// The display name of the player.
    let name: String
    /// The URL string for the player's image.
    let imagePath: String?
    enum CodingKeys: String, CodingKey { case id, name = "display_name", imagePath = "image_path" }
}

/// Represents a statistical data point for a fixture (e.g., Shots on Goal).
struct FixtureStatistic: Codable, Identifiable {
    /// A composite identifier generated from type and team to ensure uniqueness in lists.
    var id: String { "\(typeId)-\(teamId)" }
    /// The ID of the statistic type.
    let typeId: Int
    /// The entity ID (Team ID) associated with this stat (varies by API version).
    let entityId: Int?
    /// The participant ID associated with this stat.
    let participantId: Int?
    /// The type definition containing the name of the stat.
    let type: StatType?
    /// The container for the actual numerical value.
    let data: StatValue?
    
    /// A helper to resolve the team ID from either `entityId` or `participantId`.
    var teamId: Int { return entityId ?? participantId ?? 0 }
    
    enum CodingKeys: String, CodingKey { case typeId = "type_id", entityId = "entity_id", participantId = "participant_id", type, data }
}

/// The definition of a statistic type.
struct StatType: Codable {
    let name: String?
    let code: String?
}

/// A wrapper for the statistical value, handling potential type mismatches (Int vs Double).
struct StatValue: Codable {
    /// The numerical value of the statistic.
    let value: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let d = try? container.decode(Double.self, forKey: .value) { value = d }
        else if let i = try? container.decode(Int.self, forKey: .value) { value = Double(i) }
        else { value = 0.0 }
    }
    enum CodingKeys: String, CodingKey { case value }
}

/// Represents a player's inclusion in the team lineup for a specific match.
struct Lineup: Codable, Identifiable {
    /// The unique identifier of the lineup entry.
    let id: Int
    /// The ID of the team this lineup belongs to.
    let teamId: Int
    /// The player details.
    let player: Player?
    /// The ID representing the position on the field.
    let positionId: Int?
    /// The type ID (used to distinguish starters vs bench, often 11 for starters).
    let typeId: Int?
    
    /// Derives a readable position category based on the `positionId`.
    ///
    /// - Returns: "Goalkeeper", "Defender", "Midfielder", "Attacker", or "Substitute".
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

// MARK: - Fixture Extension Helpers

extension Fixture {
    /// Returns the participant ID for the home team.
    var homeTeamId: Int? { participants?.first(where: { $0.meta?.location == "home" })?.id }
    
    /// Returns the participant ID for the away team.
    var awayTeamId: Int? { participants?.first(where: { $0.meta?.location == "away" })?.id }
    
    /// Returns the current goal count for the home team, if available.
    var currentHomeGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "home" }?.score?.goals }
    
    /// Returns the current goal count for the away team, if available.
    var currentAwayGoals: Int? { scores?.first { $0.description == "CURRENT" && $0.score?.participant == "away" }?.score?.goals }
    
    /// Returns the display name of the home team, defaulting to "Home" if unavailable.
    var homeTeamName: String { participants?.first(where: { $0.meta?.location == "home" })?.name ?? "Home" }
    
    /// Returns the display name of the away team, defaulting to "Away" if unavailable.
    var awayTeamName: String { participants?.first(where: { $0.meta?.location == "away" })?.name ?? "Away" }
}
