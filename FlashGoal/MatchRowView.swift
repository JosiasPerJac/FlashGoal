//
//  MatchRowView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

struct MatchRowView: View {
    let fixture: Fixture
    
    var body: some View {
        HStack(spacing: 0) {
            
            TeamRowItem(
                name: fixture.homeTeamName,
                imagePath: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath,
                alignment: .trailing
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(spacing: 4) {
                if let homeGoals = fixture.currentHomeGoals,
                   let awayGoals = fixture.currentAwayGoals {
                    
                    Text("\(homeGoals) - \(awayGoals)")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                    
                } else {
                    
                    Text(formatTime(fixture.startingAt))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.blue)
                    
                    Text(formatDate(fixture.startingAt))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
            }
            .frame(width: 80)
            
            TeamRowItem(
                name: fixture.awayTeamName,
                imagePath: fixture.participants?.first(where: { $0.meta?.location == "away" })?.imagePath,
                alignment: .leading
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(height: 70)
        .glassCardStyle()
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

private struct TeamRowItem: View {
    let name: String
    let imagePath: String?
    let alignment: HorizontalAlignment
    
    var body: some View {
        HStack(spacing: 10) {
            if alignment == .trailing {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            AsyncImage(url: URL(string: imagePath ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    Circle().fill(.white.opacity(0.1))
                }
            }
            .frame(width: 35, height: 35)
            
            if alignment == .leading {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}
