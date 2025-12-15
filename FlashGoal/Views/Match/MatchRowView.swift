//
//  MatchRowView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// A list row component displaying a summary of a match fixture.
///
/// This view handles two main states:
/// 1. **Upcoming:** Displays the start time and date.
/// 2. **Live/Ended:** Displays the current score and status (e.g., "FT", "LIVE").
struct MatchRowView: View {
    /// The fixture data to display.
    let fixture: Fixture
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            TeamColumn(
                name: fixture.homeTeamName,
                imagePath: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath
            )
            
            VStack(spacing: 6) {
                if let homeGoals = fixture.currentHomeGoals,
                   let awayGoals = fixture.currentAwayGoals {
                    
                    Text("\(homeGoals) - \(awayGoals)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(getShortStatus(fixture.resultInfo))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                    
                } else {
                    Text(formatTime(fixture.startingAt))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(formatDate(fixture.startingAt))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                }
            }
            .frame(width: 100)
            
            TeamColumn(
                name: fixture.awayTeamName,
                imagePath: fixture.participants?.first(where: { $0.meta?.location == "away" })?.imagePath
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .glassCardStyle()
    }
    
    /// Converts raw status strings into short abbreviations.
    ///
    /// - Parameter status: The raw status string (e.g., "Ended").
    /// - Returns: An abbreviation like "FT", "LIVE", or "PP".
    func getShortStatus(_ status: String?) -> String {
        guard let status = status?.lowercased() else { return "" }
        if status.contains("ended") || status.contains("won") || status.contains("draw") {
            return "FT"
        }
        if status.contains("live") { return "LIVE" }
        if status.contains("postponed") { return "PP" }
        return "vs"
    }
    
    // MARK: - Helpers for date formatting
    private func formatTime(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "--:--" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return "--:--"
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date.formatted(.dateTime.day().month())
        }
        return ""
    }
}

/// A subview for `MatchRowView` representing a single team's logo and name.
struct TeamColumn: View {
    let name: String
    let imagePath: String?
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: imagePath ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    Circle()
                        .fill(.white.opacity(0.1))
                }
            }
            .frame(width: 42, height: 42)
            
            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
