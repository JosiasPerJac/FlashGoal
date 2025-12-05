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
    func fetchFixtures(date: Date) async throws -> [Fixture]
    func fetchStandings(seasonId: Int) async throws -> [StandingData]
    func searchPlayers(query: String) async throws -> [Player]
}

final class FootballRepository: FootballRepositoryProtocol {
    private let client: SportmonksClient
    
    init(client: SportmonksClient = .shared) {
        self.client = client
    }
    
    // MARK: - Leagues & Seasons
    func fetchLeague(id: Int) async throws -> League {
        let endpoint = "leagues/\(id)"
        let response: LeagueResponse = try await client.request(
            endpoint: endpoint,
            includes: ["currentSeason"]
        )
        return response.data
    }
    
    func fetchCurrentSeasonId(leagueId: Int) async throws -> Int {
        let league = try await fetchLeague(id: leagueId)
        guard let seasonId = league.currentSeasonId else {
            throw APIError.decodingError(
                NSError(domain: "FootballRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active season found for league \(leagueId)"])
            )
        }
        return seasonId
    }
    
    // MARK: - Fixtures
    func fetchFixtures(date: Date) async throws -> [Fixture] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let endpoint = "fixtures/date/\(dateString)"
        
        let includes = [
            "participants",
            "scores",
            "venue",
            "statistics.type",
            "lineups.player",
            "lineups.details.type"
        ]
        
        let response: FixturesResponse = try await client.request(
            endpoint: endpoint,
            includes: includes
        )
        
        let allFixtures = response.data ?? []
        let ourLeagues = Set(LeagueConstants.supportedLeagues)
        
        return allFixtures.filter { fixture in
            ourLeagues.contains(fixture.leagueId)
        }
    }
    
    // MARK: - Standings
    func fetchStandings(seasonId: Int) async throws -> [StandingData] {
        let endpoint = "standings/seasons/\(seasonId)"
        
        let includes = ["participant", "details.type"]
        
        let response: StandingsResponse = try await client.request(
            endpoint: endpoint,
            includes: includes
        )
        
        return response.data
    }
    
    // MARK: - Player Search (NEW)
    func searchPlayers(query: String) async throws -> [Player] {
        let endpoint = "players/search/\(query)"
        
        let response: PlayerSearchResponse = try await client.request(endpoint: endpoint)
        return response.data
    }
    
    // MARK: - Player Detail
        func fetchPlayerDetail(playerId: Int) async throws -> PlayerDetail {
            let endpoint = "players/\(playerId)"
            
            let includes = [
                "nationality",
                "position",
                "statistics.details.type",
                "teams.team" 
            ]
            
            let response: PlayerDetailResponse = try await client.request(
                endpoint: endpoint,
                includes: includes
            )
            return response.data
        }
}
