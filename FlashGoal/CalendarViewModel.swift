//
//  CalendarViewModel.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation
import Observation

@Observable
final class CalendarViewModel {
    var selectedDate: Date = Date()
    var isLoading: Bool = false
    var errorMessage: String?
    
    var scottishFixtures: [Fixture] = []
    var danishFixtures: [Fixture] = []
    
    private let repository: FootballRepositoryProtocol
    
    init(repository: FootballRepositoryProtocol = FootballRepository()) {
        self.repository = repository
    }
    
    // MARK: - Actions
    
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
    
    private func processFixtures(_ fixtures: [Fixture]) {
        self.scottishFixtures = fixtures.filter { $0.leagueId == LeagueConstants.scottishPremiershipId }
        self.danishFixtures = fixtures.filter { $0.leagueId == LeagueConstants.danishSuperligaId }
    }
}
