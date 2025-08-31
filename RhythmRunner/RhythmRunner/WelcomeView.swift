//
//  WelcomeView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var showPressAnywhereText = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? 
                                  [Color.black, Color.purple.opacity(0.8), Color.black] : 
                                  [Color.white, Color.blue.opacity(0.3), Color.purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main content container - using golden ratio for positioning
                VStack(spacing: 24) {
                    // Logo placeholder - elevated as primary focal point
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .shadow(color: .purple.opacity(0.3), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: "figure.run")
                            .font(.custom("SF Pro Display", size: 42, relativeTo: .largeTitle))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // Text hierarchy - clear visual hierarchy with proper spacing
                    VStack(spacing: 8) {
                        // App name - primary heading
                        Text("RhythmRunner")
                            .font(.custom("SF Pro Display", size: 28, relativeTo: .title))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .opacity(logoOpacity)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        // Tagline - secondary text with reduced emphasis
                        Text("Run to the Beat")
                            .font(.custom("SF Pro Text", size: 16, relativeTo: .body))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                            .opacity(logoOpacity)
                    }
                }
                
                Spacer()
                
                // Press anywhere to start text - subtle and minimal
                if showPressAnywhereText {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.tap")
                            .font(.custom("SF Pro Text", size: 14, relativeTo: .caption))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4))
                        
                        Text("Tap to continue")
                            .font(.custom("SF Pro Text", size: 13, relativeTo: .caption))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showPressAnywhereText ? 0.8 : 0.0)
                    .scaleEffect(showPressAnywhereText ? 1.0 : 0.9)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: showPressAnywhereText)
                }
                
                Spacer(minLength: 60)
            }
        }
        .onTapGesture {
            if showPressAnywhereText {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
        .onAppear {
            // Animate logo appearance
            withAnimation(.easeInOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Show "press anywhere" text after logo animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showPressAnywhereText = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
                .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    WelcomeView()
}
