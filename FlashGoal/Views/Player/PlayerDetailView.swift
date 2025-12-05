//
//  PlayerDetailView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

struct PlayerDetailView: View {
    let playerId: Int
    
    @State private var player: PlayerDetail?
    @State private var isLoading = true
    
    private let repository = FootballRepository()
    
    var bestStats: [StatDetail]? {
        guard let allStats = player?.statistics else { return nil }
        return allStats.max(by: { seasonA, seasonB in
            let appsA = getRawValue(details: seasonA.details, typeId: 321)
            let appsB = getRawValue(details: seasonB.details, typeId: 321)
            return appsA < appsB
        })?.details
    }

    var careerHistory: [PlayerTeamHistory] {
        guard let teams = player?.teams else { return [] }
        return teams.sorted { ($0.start ?? "") > ($1.start ?? "") }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView().tint(.white).padding(.top, 50)
                } else if let player = player {
                    
                    VStack(spacing: 16) {
                        AsyncImage(url: URL(string: player.imagePath ?? "")) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Circle().fill(.white.opacity(0.1))
                                .overlay(Image(systemName: "person.fill").font(.largeTitle))
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 2))
                        .shadow(radius: 10)
                        
                        VStack(spacing: 4) {
                            Text(player.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(player.position?.name ?? "Player")
                                .foregroundStyle(.secondary)
                                .fontWeight(.medium)
                            
                            if let country = player.nationality?.name {
                                HStack(spacing: 6) {
                                    AsyncImage(url: URL(string: player.nationality?.imagePath ?? "")) { img in
                                        img.resizable().scaledToFit()
                                    } placeholder: { Color.clear }
                                    .frame(width: 20, height: 15)
                                    
                                    Text(country)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassCardStyle()
                    
                    if let stats = bestStats {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Current Season Stats")
                                .font(.headline)
                                .padding(.leading, 4)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                StatBox(title: "Goals", value: getStat(stats, typeId: 52))
                                StatBox(title: "Assists", value: getStat(stats, typeId: 79))
                                StatBox(title: "Appearances", value: getStat(stats, typeId: 321))
                            }
                        }
                    }
                    
                    if !careerHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Career")
                                .font(.headline)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 0) {
                                ForEach(careerHistory) { history in
                                    CareerRow(history: history)
                                    
                                    if history.id != careerHistory.last?.id {
                                        Divider().background(.white.opacity(0.1))
                                    }
                                }
                            }
                            .padding()
                            .glassCardStyle()
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppBackground())
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                player = try await repository.fetchPlayerDetail(playerId: playerId)
            } catch {
                print("Error loading player: \(error)")
            }
            isLoading = false
        }
    }
    
    func getStat(_ details: [StatDetail], typeId: Int) -> String {
        if let val = details.first(where: { $0.typeId == typeId })?.value.total {
            return "\(Int(val))"
        }
        return "-"
    }
    
    func getRawValue(details: [StatDetail]?, typeId: Int) -> Double {
        return details?.first(where: { $0.typeId == typeId })?.value.total ?? 0
    }
}

struct CareerRow: View {
    let history: PlayerTeamHistory
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: history.team?.imagePath ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    Circle().fill(.white.opacity(0.1))
                }
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(history.team?.name ?? "Unknown Team")
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(history.formattedPeriod)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCardStyle()
    }
}
