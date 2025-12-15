//
//  MatchDetailView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// The main detail screen for a specific football match.
///
/// This view aggregates several card components to display the scoreboard,
/// match statistics, timeline events, and lineups.
struct MatchDetailView: View {
    /// The fixture object containing all match data.
    let fixture: Fixture
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Scoreboard (Header)
                ScoreboardCard(fixture: fixture)
                
                // Statistics (Possession, Shots, etc.)
                if let stats = fixture.statistics, !stats.isEmpty {
                    MatchStatsCard(fixture: fixture, stats: stats)
                }
                
                // Timeline (Goals, Cards)
                if let events = fixture.events, !events.isEmpty {
                    MatchEventsCard(fixture: fixture)
                }
                
                // Lineups (Starting XI)
                if let lineups = fixture.lineups, !lineups.isEmpty {
                    NavigationLink(destination: LineupsView(fixture: fixture, lineups: lineups)) {
                        PlayerStatsCard(fixture: fixture, lineups: lineups)
                    }
                    .buttonStyle(.plain)
                }
                
                Color.clear.frame(height: 50)
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Details & Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}
