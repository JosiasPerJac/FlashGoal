//
//  ScoreboardCard.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

struct ScoreboardCard: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(spacing: 20) {

            Text(fixture.resultInfo ?? "Upcoming")
                .font(.caption2)
                .fontWeight(.heavy)
                .textCase(.uppercase)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.red.gradient)
                .clipShape(Capsule())
                .shadow(radius: 5)
            
            HStack(alignment: .center) {

                TeamVerticalView(
                    name: fixture.homeTeamName,
                    imagePath: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath
                )
                
                Spacer()
                
                if let homeGoals = fixture.currentHomeGoals,
                   let awayGoals = fixture.currentAwayGoals {
                    Text("\(homeGoals) : \(awayGoals)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.2), radius: 10)
                } else {
                    Text("VS")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                TeamVerticalView(
                    name: fixture.awayTeamName,
                    imagePath: fixture.participants?.first(where: { $0.meta?.location == "away" })?.imagePath
                )
            }
            .padding(.horizontal)
            
            if let venueName = fixture.venue?.name {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(venueName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 24)
        .glassEffect()
    }
}
