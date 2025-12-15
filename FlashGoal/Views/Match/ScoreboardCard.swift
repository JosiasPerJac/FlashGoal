//
//  ScoreboardCard.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// A prominent card view displaying the current score, status, and goal scorers.
struct ScoreboardCard: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(spacing: 0) {
            Text(fixture.resultInfo ?? "Upcoming")
                .font(.caption2)
                .fontWeight(.heavy)
                .textCase(.uppercase)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.top, 24)
            
            HStack(alignment: .center) {
                TeamVerticalView(
                    name: fixture.homeTeamName,
                    imagePath: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath
                )
                
                Spacer()
                
                if let homeGoals = fixture.currentHomeGoals,
                   let awayGoals = fixture.currentAwayGoals {
                    VStack(spacing: 4) {
                        Text("\(homeGoals) : \(awayGoals)")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 4)
                        
                        if fixture.resultInfo?.contains("LIVE") ?? false {
                            Text("LIVE")
                                .font(.caption).fontWeight(.bold).foregroundStyle(.red)
                        }
                    }
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
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            GoalScorersSection(fixture: fixture)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            if let venueName = fixture.venue?.name {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(venueName)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 24)
            }
        }
        .background {
            ZStack {
                Color.black.opacity(0.6)
                if let venueImage = fixture.venue?.imagePath {
                    AsyncImage(url: URL(string: venueImage)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                                .blur(radius: 1.0)
                                .overlay(Color.black.opacity(0.6))
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

struct GoalScorersSection: View {
    let fixture: Fixture
    
    var body: some View {
        let events = fixture.events ?? []
        let goals = events.filter { $0.eventName.lowercased().contains("goal") || $0.eventName.lowercased().contains("penalty") }
        
        if goals.isEmpty {
            EmptyView()
        } else {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(goals.filter { $0.participantId == fixture.homeTeamId }) { event in
                        HStack(spacing: 4) {
                            Text(event.player?.name ?? "Goal")
                            Text(event.displayTime).foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .font(.caption).fontWeight(.medium).foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(goals.filter { $0.participantId == fixture.awayTeamId }) { event in
                        HStack(spacing: 4) {
                            Text(event.player?.name ?? "Goal")
                            Text(event.displayTime).foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .font(.caption).fontWeight(.medium).foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 10)
            .overlay(
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.2), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 1)
                    .padding(.top, -5),
                alignment: .top
            )
        }
    }
}
