//
//  FootballRepository.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

protocol FootballRepositoryProtocol {
    func fetchLeague(id: Int) async throws -> League
    func fetchCurrentSeasonId(leagueId: Int) async throws -> Int
}

final class FootballRepository: FootballRepositoryProtocol {
    // ID for future testing purposes
    private let client: SportmonksClient
    
    init(client: SportmonksClient = .shared) {
        self.client = client
    }
    
    // League info
    func fetchLeague(id: Int) async throws -> League {
        let endpoint = "leagues/\(id)"
        let response: LeagueResponse = try await client.request(
            endpoint: endpoint,
            includes: ["currentSeason"]
        )
        return response.data
    }
    
    // Helper to obtain specific season ID of the league
    func fetchCurrentSeasonId(leagueId: Int) async throws -> Int {
        let league = try await fetchLeague(id: leagueId)
        guard let seasonId = league.currentSeasonId else {
            throw APIError.decodingError(
                NSError(domain: "FootballRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active season found for league \(leagueId)"])
            )
        }
        return seasonId
    }
    
    func fetchFixtures(date: Date) async throws -> [Fixture] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let endpoint = "fixtures/date/\(dateString)"
        
        let includes = ["participants", "scores", "venue"]
        
        let response: FixturesResponse = try await client.request(
            endpoint: endpoint,
            includes: includes
        )
        
        let allFixtures = response.data ?? []
        
        let ourLeagues = Set(LeagueConstants.supportedLeagues)
        let filteredFixtures = allFixtures.filter { fixture in
            ourLeagues.contains(fixture.leagueId)
        }
        
        return filteredFixtures
    }
}
