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
                .background(.ultraThinMaterial)
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
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 4)
                } else {
                    Text("VS")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
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
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 30)
        .background {
            ZStack {
                Color.black.opacity(0.6)
                
                if let venueImage = fixture.venue?.imagePath {
                    AsyncImage(url: URL(string: venueImage)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                
                                .blur(radius: 0.8)
                                
                                .overlay(Color.black.opacity(0.5))
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}
