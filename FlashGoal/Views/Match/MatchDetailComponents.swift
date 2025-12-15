//
//  MatchDetailComponents.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// A vertical view displaying a team's logo and name.
struct TeamVerticalView: View {
    let name: String
    let imagePath: String?
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: imagePath ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .overlay(Image(systemName: "shield.fill").foregroundStyle(.white.opacity(0.3)))
                }
            }
            .frame(width: 60, height: 60)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            
            Text(name)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 100)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
}

/// A small team logo primarily used in lists or stats.
struct TeamLogoSmall: View {
    let url: String?
    
    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Circle().fill(.gray.opacity(0.2))
        }
        .frame(width: 24, height: 24)
    }
}
