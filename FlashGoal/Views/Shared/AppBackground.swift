//
//  AppBackground.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import SwiftUI

/// A reusable background view with animated gradients.
struct AppBackground: View {
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            GeometryReader { proxy in

                Circle()
                    .fill(.blue.opacity(0.15))
                    .blur(radius: 80)
                    .frame(width: 300, height: 300)
                    .position(
                        x: animate ? proxy.size.width * 0.2 : proxy.size.width * 0.8,
                        y: animate ? proxy.size.height * 0.2 : proxy.size.height * 0.8
                    )
                
                Circle()
                    .fill(.indigo.opacity(0.15))
                    .blur(radius: 80)
                    .frame(width: 250, height: 250)
                    .position(
                        x: animate ? proxy.size.width * 0.8 : proxy.size.width * 0.2,
                        y: animate ? proxy.size.height * 0.6 : proxy.size.height * 0.4
                    )
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
        }
    }
}

/// A view modifier that applies a glassmorphism effect to a view.
struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    /// Applies the standard glass card style to the view.
    func glassCardStyle() -> some View {
        modifier(GlassCardModifier())
    }
}
