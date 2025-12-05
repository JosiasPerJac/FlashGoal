//
//  LineupsView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

struct LineupsView: View {
    let fixture: Fixture
    let lineups: [Lineup]
    
    @State private var selectedTeamId: Int
    
    init(fixture: Fixture, lineups: [Lineup]) {
        self.fixture = fixture
        self.lineups = lineups
        _selectedTeamId = State(initialValue: fixture.homeTeamId ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Team", selection: $selectedTeamId) {
                Text(fixture.homeTeamName).tag(fixture.homeTeamId ?? 0)
                Text(fixture.awayTeamName).tag(fixture.awayTeamId ?? 0)
            }
            .pickerStyle(.segmented)
            .padding()
            
            ScrollView {
                VStack(spacing: 24) {
                    let teamLineups = lineups.filter { $0.teamId == selectedTeamId }
                    
                    if teamLineups.isEmpty {
                        ContentUnavailableView(
                            "No Lineups",
                            systemImage: "tshirt",
                            description: Text("Lineup information is not available yet.")
                        )
                        .padding(.top, 40)
                    } else {
                        let grouped = Dictionary(grouping: teamLineups, by: { $0.positionCategory })
                        
                        let order = ["Goalkeeper", "Defender", "Midfielder", "Attacker", "Substitute"]
                        
                        ForEach(order, id: \.self) { category in
                            if let players = grouped[category], !players.isEmpty {
                                PositionSection(title: category, players: players)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(AppBackground())
        .navigationTitle("Lineups")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PositionSection: View {
    let title: String
    let players: [Lineup]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                ForEach(players) { lineup in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: lineup.player?.imagePath ?? "")) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Circle()
                                    .fill(.white.opacity(0.1))
                                    .overlay(Image(systemName: "person.fill").foregroundStyle(.white.opacity(0.3)))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                        
                        Text(lineup.player?.name ?? "Unknown")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    if lineup.id != players.last?.id {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
