//
//  HomeView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// The home screen displaying fixtures for selected leagues and dates.
struct HomeView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var selectedLeagueTab: Int = LeagueConstants.scottishPremiershipId
    @State private var showCalendarPicker: Bool = false
    
    @State private var scottishLeague: League?
    @State private var danishLeague: League?
    private let repository = FootballRepository()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 20) {
                    CalendarStripView(selectedDate: $viewModel.selectedDate)
                        .padding(.top)
                    
                    LeagueSwitcherView(
                        selectedTab: $selectedLeagueTab,
                        scottishLogo: scottishLeague?.imagePath,
                        danishLogo: danishLeague?.imagePath
                    )
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if viewModel.isLoading {
                                ProgressView().tint(.white).padding(.top, 50)
                            } else if let error = viewModel.errorMessage {
                                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error)).padding(.top, 50)
                            } else if activeFixtures.isEmpty {
                                ContentUnavailableView("No matches", systemImage: "sportscourt", description: Text("No games scheduled for this date.")).padding(.top, 50)
                            } else {
                                ForEach(activeFixtures) { fixture in
                                    NavigationLink(destination: MatchDetailView(fixture: fixture)) {
                                        MatchRowView(fixture: fixture)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                        .safeAreaPadding(.bottom, 80)
                    }
                    .refreshable { await viewModel.loadFixtures() }
                }
            }
            .navigationTitle("FlashGoal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCalendarPicker.toggle() } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .bold))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showCalendarPicker) {
                VStack {
                    DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    Button("Confirm") { showCalendarPicker = false }
                        .buttonStyle(.borderedProminent)
                        .padding()
                }
                .presentationDetents([.medium])
            }
            .task(id: viewModel.selectedDate) {
                await viewModel.loadFixtures()
            }
            .task {
                do {
                    async let scot = repository.fetchLeague(id: LeagueConstants.scottishPremiershipId)
                    async let danish = repository.fetchLeague(id: LeagueConstants.danishSuperligaId)
                    
                    self.scottishLeague = try await scot
                    self.danishLeague = try await danish
                } catch {
                    print("Error loading league logos: \(error)")
                }
            }
        }
    }
    
    var activeFixtures: [Fixture] {
        switch selectedLeagueTab {
        case LeagueConstants.scottishPremiershipId:
            return viewModel.scottishFixtures
        case LeagueConstants.danishSuperligaId:
            return viewModel.danishFixtures
        default:
            return []
        }
    }
}

struct LeagueSwitcherView: View {
    @Binding var selectedTab: Int
    var scottishLogo: String? = nil
    var danishLogo: String? = nil
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            LeagueTabButton(
                title: "Premiership",
                logoUrl: scottishLogo,
                isSelected: selectedTab == LeagueConstants.scottishPremiershipId,
                animation: animation,
                action: { withAnimation(.snappy) { selectedTab = LeagueConstants.scottishPremiershipId } }
            )
            
            LeagueTabButton(
                title: "Superliga",
                logoUrl: danishLogo,
                isSelected: selectedTab == LeagueConstants.danishSuperligaId,
                animation: animation,
                action: { withAnimation(.snappy) { selectedTab = LeagueConstants.danishSuperligaId } }
            )
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct LeagueTabButton: View {
    let title: String
    let logoUrl: String?
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let url = logoUrl {
                    AsyncImage(url: URL(string: url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit()
                        } else {
                            Circle().fill(.white.opacity(0.2))
                        }
                    }
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.blue.gradient)
                        .matchedGeometryEffect(id: "LeagueTab", in: animation)
                }
            }
        }
    }
}

struct CalendarStripView: View {
    @Binding var selectedDate: Date
    
    var days: [Date] {
        let calendar = Calendar.current
        return (-3...3).compactMap { calendar.date(byAdding: .day, value: $0, to: selectedDate) }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(days, id: \.self) { date in
                    DatePill(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            withAnimation { selectedDate = date }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DatePill: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption2)
                .fontWeight(.bold)
                .textCase(.uppercase)
            
            Text(date.formatted(.dateTime.day()))
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(width: 50, height: 70)
        .foregroundStyle(isSelected ? .white : .primary)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.gradient)
                    .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }
}
