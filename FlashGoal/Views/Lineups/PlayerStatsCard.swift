//
//  PlayerStatsCard.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

struct PlayerStatsCard: View {
    let fixture: Fixture
    let lineups: [Lineup]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Lineups")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("See All")
                        .font(.caption)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            
            Divider().background(.white.opacity(0.1))
            
            let positions = ["Goalkeeper", "Attacker", "Defender"]
            let availablePositions = positions.filter { hasPlayer(for: $0) }
            
            if !availablePositions.isEmpty {
                ForEach(availablePositions.prefix(3), id: \.self) { position in
                    MatchupRow(
                        title: position,
                        homePlayer: getPlayer(category: position, teamId: fixture.homeTeamId),
                        awayPlayer: getPlayer(category: position, teamId: fixture.awayTeamId)
                    )
                    
                    if position != availablePositions.prefix(3).last {
                         Divider().background(.white.opacity(0.1))
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Text("Tap to view full squads")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .glassCardStyle()
    }
    
    private func hasPlayer(for category: String) -> Bool {
        return lineups.contains { $0.positionCategory == category }
    }
    
    private func getPlayer(category: String, teamId: Int?) -> Player? {
        guard let teamId = teamId else { return nil }
        return lineups.first { $0.teamId == teamId && $0.positionCategory == category }?.player
    }
}

struct MatchupRow: View {
    let title: String
    let homePlayer: Player?
    let awayPlayer: Player?
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Group {
                if let home = homePlayer {
                    PlayerMiniRow(player: home, alignment: .leading)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.secondary.opacity(0.8))
                .textCase(.uppercase)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: 80)
            
            Group {
                if let away = awayPlayer {
                    PlayerMiniRow(player: away, alignment: .trailing)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 6)
    }
}

struct PlayerMiniRow: View {
    let player: Player
    let alignment: HorizontalAlignment
    
    var body: some View {
        HStack(spacing: 8) {
            if alignment == .trailing {
                Text(player.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer()
            }
            
            AsyncImage(url: URL(string: player.imagePath ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(.gray.opacity(0.3))
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
            
            if alignment == .leading {
                Spacer()
                Text(player.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
        }
    }
}
