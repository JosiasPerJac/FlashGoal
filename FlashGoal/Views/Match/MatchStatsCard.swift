//
//  MatchStatsCard.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// A card displaying a comparative list of match statistics (e.g., Shots, Possession).
///
/// This view normalizes the stats for both Home and Away teams and renders them
/// as bar charts.
struct MatchStatsCard: View {
    let fixture: Fixture
    let stats: [FixtureStatistic]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Match Stats")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TeamLogoSmall(url: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath)
                Spacer()
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(.secondary)
                Spacer()
                TeamLogoSmall(url: fixture.participants?.first(where: { $0.meta?.location == "away" })?.imagePath)
            }
            .padding(.bottom, 8)
            
            let normalizedStats = normalizeStats(stats)
            
            if normalizedStats.isEmpty {
                Text("No stats available for this match.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                VStack(spacing: 16) {
                    ForEach(normalizedStats.keys.sorted(), id: \.self) { statName in
                        if let pair = normalizedStats[statName] {
                            StatRow(
                                title: statName,
                                homeValue: pair.home,
                                awayValue: pair.away
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .glassCardStyle()
    }
    
    /// Organizes the flat list of statistics into pairs of (Home Value, Away Value).
    ///
    /// - Parameter rawStats: The raw list of statistics from the API.
    /// - Returns: A dictionary where key is the stat name and value is the tuple of home/away scores.
    private func normalizeStats(_ rawStats: [FixtureStatistic]) -> [String: (home: Double, away: Double)] {
        var result: [String: (home: Double, away: Double)] = [:]
        
        let homeId = fixture.homeTeamId ?? -1
        let awayId = fixture.awayTeamId ?? -1
        
        // Group by stat name
        let grouped = Dictionary(grouping: rawStats) { stat in
            return stat.type?.name ?? stat.type?.code ?? "Unknown Stat"
        }
        
        for (name, statsList) in grouped {
            var current = (home: 0.0, away: 0.0)
            
            // Attempt to match by Team ID
            let homeStat = statsList.first { $0.teamId == homeId }
            let awayStat = statsList.first { $0.teamId == awayId }
            
            if homeStat != nil || awayStat != nil {
                current.home = homeStat?.data?.value ?? 0
                current.away = awayStat?.data?.value ?? 0
            } else {
                // Fallback for when IDs might be missing/mismatched but order is consistent
                if statsList.indices.contains(0) { current.home = statsList[0].data?.value ?? 0 }
                if statsList.indices.contains(1) { current.away = statsList[1].data?.value ?? 0 }
            }
            
            if name != "Unknown Stat" {
                result[name] = current
            }
        }
        
        return result
    }
}

/// A single row representing one statistic (e.g. "Shots") with a dual bar chart.
private struct StatRow: View {
    let title: String
    let homeValue: Double
    let awayValue: Double
    
    var body: some View {
        let total = homeValue + awayValue
        let homePercent = total > 0 ? (homeValue / total) : 0.5
        
        VStack(spacing: 8) {
            HStack {
                Text("\(Int(homeValue))")
                    .fontWeight(.bold)
                    .frame(width: 40, alignment: .leading)
                
                Spacer()
                Text(title)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
                
                Text("\(Int(awayValue))")
                    .fontWeight(.bold)
                    .frame(width: 40, alignment: .trailing)
            }
            
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue.gradient)
                        .frame(width: proxy.size.width * CGFloat(homePercent))
                    
                    Rectangle()
                        .fill(Color.red.gradient)
                        .frame(width: proxy.size.width * (1.0 - CGFloat(homePercent)))
                }
            }
            .frame(height: 8)
            .clipShape(Capsule())
        }
    }
}
