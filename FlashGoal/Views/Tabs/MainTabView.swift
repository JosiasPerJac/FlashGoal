//
//  MainTabView.swift
//  FlashGoal
//
//  Created by Josias Pérez on 5/12/25.
//

import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Matches", systemImage: "sportscourt")
                }
            
            StandingsView()
                .tabItem {
                    Label("Standings", systemImage: "trophy")
                }
            
            PlayersView()
                .tabItem {
                    Label("Players", systemImage: "figure.indoor.soccer")
                }
        }
        .tint(.blue)
    }
}
