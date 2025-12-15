//
//  MatchEventsCard.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

/// A card view displaying the timeline of key events (Goals, Cards, Substitutions).
struct MatchEventsCard: View {
    let fixture: Fixture
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Match Events")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TeamLogoSmall(url: fixture.participants?.first(where: { $0.meta?.location == "home" })?.imagePath)
                Spacer()
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Spacer()
                TeamLogoSmall(url: fixture.participants?.first(where: { $0.meta?.location == "away" })?.imagePath)
            }
            .padding(.bottom, 8)
            
            Divider().background(.white.opacity(0.1))
            
            let events = (fixture.events ?? [])
                .filter { $0.isImportant }
                .sorted(by: { ($0.minute ?? 0) < ($1.minute ?? 0) })
            
            if events.isEmpty {
                ContentUnavailableView("No Events", systemImage: "clock.arrow.circlepath", description: Text("Timeline empty."))
            } else {
                VStack(spacing: 12) {
                    ForEach(events) { event in
                        TimelineRow(event: event, isHome: event.participantId == fixture.homeTeamId)
                    }
                }
            }
        }
        .padding(20)
        .glassCardStyle()
    }
}

/// A single row in the timeline. Events for the Home team align left; Away team align right.
struct TimelineRow: View {
    let event: FixtureEvent
    let isHome: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            HStack(spacing: 8) {
                if isHome {
                    Spacer()
                    
                    Text(event.player?.name ?? event.eventName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                    
                    Image(systemName: event.iconName)
                        .foregroundStyle(event.iconColor)
                        .font(.caption2)
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            
            TimeBubble(time: event.displayTime)
            
            HStack(spacing: 8) {
                if !isHome {
                    Image(systemName: event.iconName)
                        .foregroundStyle(event.iconColor)
                        .font(.caption2)
                    
                    Text(event.player?.name ?? event.eventName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Spacer()
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// A bubble displaying the minute of the event.
struct TimeBubble: View {
    let time: String
    var body: some View {
        Text(time)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.black)
            .frame(width: 35, height: 20)
            .background(.white)
            .clipShape(Capsule())
    }
}
