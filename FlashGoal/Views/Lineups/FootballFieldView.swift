//
//  FootballFieldView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

/// A graphical representation of a football pitch showing player formations.
///
/// This view takes a list of starting players and distributes them vertically on a pitch
/// based on their position category (Goalkeeper, Defender, Midfielder, Attacker).
struct FootballFieldView: View {
    /// The list of players in the starting lineup.
    let lineups: [Lineup]
    
    var body: some View {
        ZStack {
            // 1. The Pitch Graphics
            FieldBackground()
            
            // 2. The Formation Layer
            VStack(spacing: 0) {
                
                Spacer()
                
                // TOP ROW: Attackers
                PlayerLine(players: getPlayers(for: "Attacker"))
                
                Spacer()
                
                // MIDDLE ROW: Midfielders
                PlayerLine(players: getPlayers(for: "Midfielder"))
                
                Spacer()
                
                // DEFENSE ROW: Defenders
                PlayerLine(players: getPlayers(for: "Defender"))
                
                Spacer()
                
                // BOTTOM ROW: Goalkeeper
                PlayerLine(players: getPlayers(for: "Goalkeeper"))
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
    
    /// Filters and sorts players for a specific position row.
    ///
    /// - Parameter position: The position category name.
    /// - Returns: A sorted list of players for that row.
    func getPlayers(for position: String) -> [Lineup] {
        return lineups.filter { $0.positionCategory == position }.sorted { $0.id < $1.id }
    }
}

/// A horizontal container for a specific line of players (e.g., Defense line).
struct PlayerLine: View {
    let players: [Lineup]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(players) { player in
                FieldPlayerIcon(player: player.player)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

/// A visual icon for a single player on the field, showing their avatar and name.
struct FieldPlayerIcon: View {
    let player: Player?
    
    var body: some View {
        VStack(spacing: 4) {
            // Avatar
            AsyncImage(url: URL(string: player?.imagePath ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(.white)
                        .overlay(Text(String(player?.name.prefix(1) ?? "?")).foregroundStyle(.black).bold())
                }
            }
            .frame(width: 45, height: 45)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .shadow(radius: 4)
            
            // Name Tag
            Text(formatName(player?.name))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.black.opacity(0.6))
                .clipShape(Capsule())
        }
    }
    
    /// Formats the player's name to display only the last name or a short version.
    func formatName(_ name: String?) -> String {
        guard let name = name else { return "Unknown" }
        let parts = name.split(separator: " ")
        if let last = parts.last { return String(last) }
        return name
    }
}

/// The background drawing of the football pitch (grass, lines, boxes).
struct FieldBackground: View {
    var body: some View {
        ZStack {
            // Grass Green
            Color(red: 0.18, green: 0.5, blue: 0.2)
            
            // Grass Stripes
            HStack(spacing: 0) {
                ForEach(0..<10) { i in
                    Color.white.opacity(i % 2 == 0 ? 0.05 : 0.0)
                }
            }
            
            // Lines
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                
                Path { path in
                    // Outer Border
                    path.addRect(CGRect(x: 10, y: 10, width: w - 20, height: h - 20))
                    
                    // Halfway Line
                    path.move(to: CGPoint(x: 10, y: h / 2))
                    path.addLine(to: CGPoint(x: w - 10, y: h / 2))
                    
                    // Center Circle
                    path.addEllipse(in: CGRect(x: w/2 - 30, y: h/2 - 30, width: 60, height: 60))
                    
                    // Top Box (Attack)
                    path.addRect(CGRect(x: w/2 - 50, y: 10, width: 100, height: 50))
                    path.addRect(CGRect(x: w/2 - 25, y: 10, width: 50, height: 20))
                    
                    // Bottom Box (Defense)
                    path.addRect(CGRect(x: w/2 - 50, y: h - 60, width: 100, height: 50))
                    path.addRect(CGRect(x: w/2 - 25, y: h - 30, width: 50, height: 20))
                }
                .stroke(.white.opacity(0.7), lineWidth: 1.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}
