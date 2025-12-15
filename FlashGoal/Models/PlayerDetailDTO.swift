//
//  PlayerDetailDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import Foundation

/// Represents the response for a detailed player profile request.
struct PlayerDetailResponse: Codable {
    /// The player profile data.
    let data: PlayerDetail
}

/// Represents the full profile of a player, including career and stats.
struct PlayerDetail: Codable, Identifiable {
    /// The unique player ID.
    let id: Int
    /// The display name.
    let name: String
    /// The player's image URL string.
    let imagePath: String?
    /// The country of nationality.
    let nationality: Country?
    /// The primary playing position.
    let position: Position?
    /// A list of statistics grouped by season.
    let statistics: [PlayerSeasonStats]?
    /// A history of teams the player has represented.
    let teams: [PlayerTeamHistory]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "display_name"
        case imagePath = "image_path"
        case nationality, position, statistics, teams
    }
}

/// Represents a period of time a player spent at a specific team.
struct PlayerTeamHistory: Codable, Identifiable {
    /// The unique identifier for this history record.
    let id: Int
    /// The team ID.
    let teamId: Int
    /// The team details (name, logo).
    let team: TeamShort?
    /// The start date of the tenure (YYYY-MM-DD).
    let start: String?
    /// The end date of the tenure (YYYY-MM-DD), or nil if currently active.
    let end: String?
    
    /// Formats the tenure into a readable string (e.g., "2021-08 - Present").
    var formattedPeriod: String {
        let s = formatDate(start)
        let e = end != nil ? formatDate(end) : "Present"
        return "\(s) - \(e)"
    }
    
    /// Helper to format date strings into "Year-Month" format.
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return date.formatted(.dateTime.year().month())
        }
        return dateString
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teamId = "team_id"
        case team
        case start, end
    }
}

/// Simplified team object for history lists.
struct TeamShort: Codable {
    let name: String
    let imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case name, imagePath = "image_path"
    }
}

/// Represents a country entity.
struct Country: Codable {
    let name: String?
    let imagePath: String?
    enum CodingKeys: String, CodingKey { case name, imagePath = "image_path" }
}

/// Represents a playing position (e.g., Midfielder).
struct Position: Codable {
    let name: String?
}

/// Container for statistics associated with a specific season.
struct PlayerSeasonStats: Codable {
    /// The season ID.
    let seasonId: Int
    /// The list of specific stats (Goals, Assists, etc.).
    let details: [StatDetail]?
    enum CodingKeys: String, CodingKey { case seasonId = "season_id", details }
}

/// A generic container for a statistic type and its value.
struct StatDetail: Codable {
    /// The ID of the statistic type.
    let typeId: Int
    /// The wrapped value of the statistic.
    let value: StatValueWrapper
    enum CodingKeys: String, CodingKey { case typeId = "type_id", value }
}

/// A robust wrapper to handle polymorphic value types in JSON (Int/Double/Object).
struct StatValueWrapper: Codable {
    /// The total value normalized to a Double.
    let total: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Try decoding as Double
        if let doubleVal = try? container.decode(Double.self) { total = doubleVal }
        // Try decoding as Int
        else if let intVal = try? container.decode(Int.self) { total = Double(intVal) }
        // Try decoding as a dictionary containing "total"
        else if let dict = try? container.decode([String: Double].self), let tot = dict["total"] { total = tot }
        else { total = 0 }
    }
}
