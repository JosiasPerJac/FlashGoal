//
//  FootballRepository.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Defines the contract for fetching football-related data.
///
/// This protocol abstracts the underlying data source (API), allowing for easier testing
/// and dependency injection within ViewModels.
protocol FootballRepositoryProtocol {
    /// Retrieves details for a specific league.
    func fetchLeague(id: Int) async throws -> League
    
    /// Retrieves the ID of the current active season for a given league.
    func fetchCurrentSeasonId(leagueId: Int) async throws -> Int
    
    /// Retrieves a list of matches scheduled for a specific date.
    func fetchFixtures(date: Date) async throws -> [Fixture]
    
    /// Retrieves the standings table for a specific season.
    func fetchStandings(seasonId: Int) async throws -> [StandingData]
    
    /// Searches for players matching a specific query string.
    func searchPlayers(query: String) async throws -> [Player]
}

/// The concrete implementation of `FootballRepositoryProtocol` using `SportmonksClient`.
///
/// This repository acts as the single source of truth for data in the app. It handles
/// endpoint selection, query parameter construction (including complex "includes"),
/// and post-processing (filtering) of data.
final class FootballRepository: FootballRepositoryProtocol {
    private let client: SportmonksClient
    
    /// Initializes the repository with a networking client.
    ///
    /// - Parameter client: The network client to use for requests. Defaults to `SportmonksClient.shared`.
    init(client: SportmonksClient = .shared) {
        self.client = client
    }
    
    // MARK: - Leagues & Seasons
    
    /// Fetches details for a specific league by its ID.
    ///
    /// - Parameter id: The unique identifier of the league.
    /// - Returns: A `League` object containing names, logos, and current season info.
    /// - Throws: An error if the network request or decoding fails.
    func fetchLeague(id: Int) async throws -> League {
        let endpoint = "leagues/\(id)"
        let response: LeagueResponse = try await client.request(
            endpoint: endpoint,
            includes: ["currentSeason"]
        )
        return response.data
    }
    
    /// Identifies the current season ID for a given league.
    ///
    /// This method first fetches the league details to inspect the `currentSeason` property.
    ///
    /// - Parameter leagueId: The ID of the league.
    /// - Returns: The integer ID of the current season.
    /// - Throws: `APIError.decodingError` (customized) if the league has no active season data.
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
    
    /// Fetches all fixtures for a given date and filters them for supported leagues.
    ///
    /// This method queries the `fixtures/date/{date}` endpoint. It requests extensive
    /// included data (participants, scores, venues, lineups, events) to populate the
    /// match detail views fully.
    ///
    /// - Note: The method performs client-side filtering to ensure only fixtures belonging
    ///         to `LeagueConstants.supportedLeagues` are returned.
    ///
    /// - Parameter date: The specific date for which to retrieve matches.
    /// - Returns: An array of `Fixture` objects sorted by the API (usually chronological).
    func fetchFixtures(date: Date) async throws -> [Fixture] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            let endpoint = "fixtures/date/\(dateString)"
            
            // Extensive includes for full match details
            let includes = [
                "participants",
                "scores",
                "venue",
                "statistics.type",
                "lineups.player",
                "lineups.details.type",
                "events.type",
                "events.player"
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
    
    /// Fetches the standings (league table) for a specific season.
    ///
    /// - Parameter seasonId: The ID of the season to fetch.
    /// - Returns: A list of `StandingData` rows, containing position, points, and team info.
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
    
    /// Performs a search for players based on a string query.
    ///
    /// - Parameter query: The name or partial name to search for.
    /// - Returns: An array of `Player` objects matching the query.
    func searchPlayers(query: String) async throws -> [Player] {
        let endpoint = "players/search/\(query)"
        
        let response: PlayerSearchResponse = try await client.request(endpoint: endpoint)
        return response.data
    }
    
    // MARK: - Player Detail
    
    /// Fetches detailed biological and statistical information for a specific player.
    ///
    /// Includes nationality, position, current season stats, and team history.
    ///
    /// - Parameter playerId: The unique identifier of the player.
    /// - Returns: A `PlayerDetail` object.
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
