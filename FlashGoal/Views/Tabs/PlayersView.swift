//
//  PlayersView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

/// Manages the state and business logic for the Player Search feature.
@Observable
class PlayersViewModel {
    /// The collection of players found by the current search query.
    var players: [Player] = []
    
    /// Indicates if a search request is currently in flight.
    var isLoading = false
    
    /// Contains error details if the search operation fails.
    var errorMessage: String?
    
    private let repository: FootballRepositoryProtocol
    private var searchTask: Task<Void, Never>?
    
    /// Initializes the ViewModel.
    init(repository: FootballRepositoryProtocol = FootballRepository()) {
        self.repository = repository
    }
    
    /// Executes a search for players matching the query.
    ///
    /// This method implements a debounce mechanism (0.5s) to prevent excessive API calls
    /// while the user is typing.
    ///
    /// - Parameter query: The text to search for (minimum 3 characters).
    @MainActor
    func search(query: String) {
        searchTask?.cancel()
        
        guard query.count > 2 else {
            players = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Debounce 0.5s
            if Task.isCancelled { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                players = try await repository.searchPlayers(query: query)
            } catch {
                errorMessage = "Failed to find players."
                print("Search Error: \(error)")
            }
            
            isLoading = false
        }
    }
}

/// The main view for the Players tab, allowing users to search and navigate to player details.
struct PlayersView: View {
    @State private var viewModel = PlayersViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search players", text: $searchText)
                            .onChange(of: searchText) { _, newValue in
                                viewModel.search(query: newValue)
                            }
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding()
                    
                    // State Handling
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                            .padding(.top, 50)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                        Spacer()
                    } else if viewModel.players.isEmpty {
                        if searchText.isEmpty {
                            ContentUnavailableView("Player Search", systemImage: "magnifyingglass", description: Text("Start typing to find players."))
                        } else {
                            ContentUnavailableView("No Results", systemImage: "person.slash", description: Text("No players found for '\(searchText)'."))
                        }
                        Spacer()
                    } else {
                        // Results List
                        List(viewModel.players, id: \.id) { player in
                            ZStack {
                                NavigationLink(destination: PlayerDetailView(playerId: player.id)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                PlayerSearchRow(player: player)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .navigationTitle("Players")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    /// A custom row view for a player in the search results.
    struct PlayerSearchRow: View {
        let player: Player
        
        var body: some View {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: player.imagePath ?? "")) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(.gray.opacity(0.3))
                            .overlay(Image(systemName: "person.fill").foregroundStyle(.white.opacity(0.3)))
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Player")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding()
            .glassCardStyle()
        }
    }
}
