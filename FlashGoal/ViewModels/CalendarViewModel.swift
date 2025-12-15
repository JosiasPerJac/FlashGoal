//
//  CalendarViewModel.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation
import Observation

/// Manages the data state for the fixtures calendar and home screen.
///
/// This ViewModel is responsible for fetching fixtures for a selected date and
/// categorizing them into the supported leagues (Scottish Premiership and Danish Superliga).
@Observable
final class CalendarViewModel {
    /// The date currently selected by the user. Triggers a fetch when changed via the UI tasks.
    var selectedDate: Date = Date()
    
    /// Indicates whether a network request is currently in progress.
    var isLoading: Bool = false
    
    /// Contains a localized description of an error if the last fetch failed.
    var errorMessage: String?
    
    /// The list of fixtures specifically for the Scottish Premiership.
    var scottishFixtures: [Fixture] = []
    
    /// The list of fixtures specifically for the Danish Superliga.
    var danishFixtures: [Fixture] = []
    
    private let repository: FootballRepositoryProtocol
    
    /// Initializes the ViewModel.
    ///
    /// - Parameter repository: The data provider. Defaults to `FootballRepository`.
    init(repository: FootballRepositoryProtocol = FootballRepository()) {
        self.repository = repository
    }
    
    // MARK: - Actions
    
    /// Asynchronously loads fixtures for the `selectedDate`.
    ///
    /// This method updates `isLoading` state, fetches data from the repository,
    /// and then categorizes the results. If an error occurs, `errorMessage` is updated.
    @MainActor
    func loadFixtures() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fixtures = try await repository.fetchFixtures(date: selectedDate)
            
            processFixtures(fixtures)
            
        } catch {
            errorMessage = "Error loading matches. Verify your connection."
            print("ViewModel Error: \(error.localizedDescription)")
            
            scottishFixtures = []
            danishFixtures = []
        }
        
        isLoading = false
    }
    
    // MARK: - Helpers
    
    /// Filters the raw list of fixtures into league-specific arrays.
    ///
    /// - Parameter fixtures: The complete list of fixtures fetched from the API.
    private func processFixtures(_ fixtures: [Fixture]) {
        self.scottishFixtures = fixtures.filter { $0.leagueId == LeagueConstants.scottishPremiershipId }
        self.danishFixtures = fixtures.filter { $0.leagueId == LeagueConstants.danishSuperligaId }
    }
}
