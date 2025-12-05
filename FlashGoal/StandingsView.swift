//
//  StandingsView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI
import Observation

@Observable
class StandingsViewModel {
    var standings: [StandingData] = []
    var isLoading = false
    var errorMessage: String?
    
    private let repository: FootballRepositoryProtocol
    
    init(repository: FootballRepositoryProtocol = FootballRepository()) {
        self.repository = repository
    }
    
    @MainActor
    func loadStandings(leagueId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let seasonId = try await repository.fetchCurrentSeasonId(leagueId: leagueId)
            let data = try await repository.fetchStandings(seasonId: seasonId)
            self.standings = data.sorted(by: { $0.position < $1.position })
        } catch {
            self.errorMessage = "Failed to load standings."
            print("Standings Error: \(error)")
        }
        
        isLoading = false
    }
}

struct StandingsView: View {
    @State private var viewModel = StandingsViewModel()
    @State private var selectedLeagueTab: Int = LeagueConstants.scottishPremiershipId
    
    @State private var scottishLeague: League?
    @State private var danishLeague: League?
    private let repository = FootballRepository()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    LeagueSwitcherView(
                        selectedTab: $selectedLeagueTab,
                        scottishLogo: scottishLeague?.imagePath,
                        danishLogo: danishLeague?.imagePath
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    HStack(spacing: 0) {
                        Text("#").frame(width: 30, alignment: .center)
                        Text("Team").frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
                        Text("P").frame(width: 30, alignment: .center)
                        Text("W").frame(width: 30, alignment: .center)
                        Text("D").frame(width: 30, alignment: .center)
                        Text("L").frame(width: 30, alignment: .center)
                        Text("Pts").frame(width: 40, alignment: .center)
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 8)
                    
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                            .frame(maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                    } else {
                        List(viewModel.standings) { row in
                            StandingRow(row: row)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadStandings(leagueId: selectedLeagueTab)
                        }
                    }
                }
            }
            .navigationTitle("Standings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedLeagueTab) { _, newValue in
                Task { await viewModel.loadStandings(leagueId: newValue) }
            }
            .task {
                await viewModel.loadStandings(leagueId: selectedLeagueTab)
                
                do {
                    async let scot = repository.fetchLeague(id: LeagueConstants.scottishPremiershipId)
                    async let danish = repository.fetchLeague(id: LeagueConstants.danishSuperligaId)
                    self.scottishLeague = try await scot
                    self.danishLeague = try await danish
                } catch {
                    print("Error loading league logos: \(error)")
                }
            }
        }
    }
}

struct StandingRow: View {
    let row: StandingData
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(row.position)")
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(width: 30, alignment: .center)
            
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: row.participant?.imagePath ?? "")) { phase in
                    if let image = phase.image { image.resizable().scaledToFit() }
                    else { Circle().fill(.gray.opacity(0.3)) }
                }
                .frame(width: 24, height: 24)
                
                Text(row.participant?.name ?? "Team")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            let played = getDetail(typeId: 129)
            let won = getDetail(typeId: 130)
            let draw = getDetail(typeId: 131)
            let lost = getDetail(typeId: 132)
            
            Group {
                Text("\(played)").frame(width: 30, alignment: .center)
                Text("\(won)").frame(width: 30, alignment: .center)
                Text("\(draw)").frame(width: 30, alignment: .center)
                Text("\(lost)").frame(width: 30, alignment: .center)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Text("\(row.points)")
                .font(.subheadline)
                .fontWeight(.heavy)
                .frame(width: 40, alignment: .center)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .glassCardStyle()
    }
    
    func getDetail(typeId: Int) -> Int {
        return row.details?.first(where: { $0.typeId == typeId })?.value ?? 0
    }
}
