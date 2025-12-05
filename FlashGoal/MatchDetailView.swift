//
//  MatchDetailView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

struct MatchDetailView: View {
    let fixture: Fixture
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ScoreboardCard(fixture: fixture)
                
                if let stats = fixture.statistics, !stats.isEmpty {
                    MatchStatsCard(fixture: fixture, stats: stats)
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.bar.xaxis",
                        description: Text("The stats will be available at the start of the match.")
                    )
                    .padding()
                    .glassCardStyle()
                }
                
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
