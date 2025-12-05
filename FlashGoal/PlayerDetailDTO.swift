//
//  PlayerDetailDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import Foundation

struct PlayerDetailResponse: Codable {
    let data: PlayerDetail
}

struct PlayerDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let imagePath: String?
    let nationality: Country?
    let position: Position?
    let statistics: [PlayerSeasonStats]?
    let teams: [PlayerTeamHistory]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "display_name"
        case imagePath = "image_path"
        case nationality, position, statistics, teams
    }
}

struct PlayerTeamHistory: Codable, Identifiable {
    let id: Int
    let teamId: Int
    let team: TeamShort?
    let start: String?
    let end: String?
    
    var formattedPeriod: String {
        let s = formatDate(start)
        let e = end != nil ? formatDate(end) : "Present"
        return "\(s) - \(e)"
    }
    
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

struct TeamShort: Codable {
    let name: String
    let imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case name, imagePath = "image_path"
    }
}

struct Country: Codable {
    let name: String?
    let imagePath: String?
    enum CodingKeys: String, CodingKey { case name, imagePath = "image_path" }
}

struct Position: Codable {
    let name: String?
}

struct PlayerSeasonStats: Codable {
    let seasonId: Int
    let details: [StatDetail]?
    enum CodingKeys: String, CodingKey { case seasonId = "season_id", details }
}

struct StatDetail: Codable {
    let typeId: Int
    let value: StatValueWrapper
    enum CodingKeys: String, CodingKey { case typeId = "type_id", value }
}

struct StatValueWrapper: Codable {
    let total: Double
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let doubleVal = try? container.decode(Double.self) { total = doubleVal }
        else if let intVal = try? container.decode(Int.self) { total = Double(intVal) }
        else if let dict = try? container.decode([String: Double].self), let tot = dict["total"] { total = tot }
        else { total = 0 }
    }
}
