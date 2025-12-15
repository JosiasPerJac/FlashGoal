//
//  SharedDTOs.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Represents a participating team in a match.
struct Participant: Codable, Identifiable {
    /// The unique identifier of the team.
    let id: Int
    /// The team's name.
    let name: String
    /// The team's logo URL.
    let imagePath: String?
    /// Metadata regarding the participant (e.g., location).
    let meta: ParticipantMeta?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
        case meta
    }
}

/// Metadata describing a participant's role in a fixture.
struct ParticipantMeta: Codable {
    /// The location of the team: "home" or "away".
    let location: String?
}

/// Represents a match venue (Stadium).
struct Venue: Codable, Identifiable {
    let id: Int
    let name: String?
    let imagePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imagePath = "image_path"
    }
}

/// Represents a score entry at a specific point or type (e.g., Current, Halftime).
struct ScoreEntry: Codable, Identifiable {
    let id: Int
    let typeId: Int?
    let participantId: Int?
    /// Description of the score type (e.g., "CURRENT").
    let description: String?
    /// The actual score values.
    let score: ScoreValue?

    enum CodingKeys: String, CodingKey {
        case id
        case typeId = "type_id"
        case participantId = "participant_id"
        case description
        case score
    }
}

/// Holds the numerical score data.
struct ScoreValue: Codable {
    /// The number of goals scored.
    let goals: Int?
    /// The side that scored ("home" or "away").
    let participant: String?
}

/// Represents the response payload for a player search operation.
struct PlayerSearchResponse: Codable {
    /// The list of players found.
    let data: [Player]
}
