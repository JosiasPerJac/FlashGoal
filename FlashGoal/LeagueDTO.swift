//
//  LeagueDTO.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

struct LeagueResponse: Codable {
    let data: League
}

struct League: Codable, Identifiable {
    let id: Int
    let name: String
    let imagePath: String?
    let currentSeason: SeasonShort?
    
    var currentSeasonId: Int? {
        return currentSeason?.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
        case currentSeason = "currentseason"
    }
}


struct SeasonShort: Codable {
    let id: Int
    let name: String?
}
