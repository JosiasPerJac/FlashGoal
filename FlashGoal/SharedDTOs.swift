//
//  SharedDTOs.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

struct Participant: Codable, Identifiable {
    let id: Int
    let name: String
    let imagePath: String?
    let meta: ParticipantMeta?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
        case meta
    }
}

struct ParticipantMeta: Codable {
    let location: String?
}

struct Venue: Codable, Identifiable {
    let id: Int
    let name: String?
    let imagePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
    }
}

struct ScoreEntry: Codable, Identifiable {
    let id: Int
    let typeId: Int?
    let participantId: Int?
    let description: String?
    let score: ScoreValue?

    enum CodingKeys: String, CodingKey {
        case id
        case typeId = "type_id"
        case participantId = "participant_id"
        case description
        case score
    }
}

struct ScoreValue: Codable {
    let goals: Int?
    let participant: String?   
}
