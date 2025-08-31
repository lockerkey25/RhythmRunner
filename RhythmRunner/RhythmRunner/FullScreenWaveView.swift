//
//  FullScreenWaveView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-31.
//

import SwiftUI

struct FullScreenWaveView: View {
    @State private var animationPhase: CGFloat = 0
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    let bpm: Double
    let primaryColor: Color
    let isPlaying: Bool
    let audioIntensity: CGFloat
    
    private let animationTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let centerX = screenWidth / 2
            let centerY = screenHeight / 2
            
            ZStack {
                // Multiple wave layers that fill the entire screen
                ForEach(0..<3, id: \.self) { layerIndex in
                    Path { path in
                        let waveHeight = screenHeight * 0.2 * (1 + audioIntensity * 0.5)
                        let frequency = 2.0 + Double(layerIndex) * 0.5
                        let phaseOffset = animationPhase + CGFloat(layerIndex) * .pi / 3
                        
                        // Start from left edge
                        path.move(to: CGPoint(x: 0, y: centerY))
                        
                        // Create sine wave across entire screen width
                        for x in stride(from: 0, through: screenWidth, by: 2) {
                            let normalizedX = x / screenWidth
                            let waveY = sin(normalizedX * .pi * frequency + phaseOffset) * waveHeight * 0.3
                            let y = centerY + waveY
                            
                            if x == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [
                                primaryColor.opacity(0.8 - Double(layerIndex) * 0.2 + audioIntensity * 0.3),
                                primaryColor.opacity(0.4 - Double(layerIndex) * 0.1 + audioIntensity * 0.2),
                                primaryColor.opacity(0.1 + audioIntensity * 0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 4 - CGFloat(layerIndex) + audioIntensity * 2,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .scaleEffect(y: 1.0 + audioIntensity * 0.5)
                    .opacity(0.7 - Double(layerIndex) * 0.1 + audioIntensity * 0.3)
                }
                
                // Radial waves emanating from center
                if isPlaying {
                    ForEach(0..<5, id: \.self) { ringIndex in
                        Circle()
                            .stroke(
                                primaryColor.opacity(0.3 - Double(ringIndex) * 0.05),
                                lineWidth: 2
                            )
                            .scaleEffect(0.2 + Double(ringIndex) * 0.3 + audioIntensity * 0.4)
                            .opacity(0.8 - Double(ringIndex) * 0.15)
                            .animation(
                                .easeInOut(duration: 60.0 / bpm)
                                .repeatForever(autoreverses: true)
                                .delay(Double(ringIndex) * 0.1),
                                value: animationPhase
                            )
                    }
                }
                
                // Vertical bars that react to audio intensity
                if isPlaying && audioIntensity > 0.1 {
                    let barCount = max(8, Int(screenWidth / 25)) // Ensure minimum bars and reasonable spacing
                    let barSpacing = screenWidth / CGFloat(barCount + 1)
                    
                    ForEach(0..<barCount, id: \.self) { barIndex in
                        let heightVariation = sin(animationPhase * 3 + CGFloat(barIndex) * 0.5)
                        let barHeight = max(10, 20 + audioIntensity * 60 * abs(heightVariation)) // Ensure positive height
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        primaryColor.opacity(0.8),
                                        primaryColor.opacity(0.3)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 3, height: barHeight)
                            .position(
                                x: barSpacing * CGFloat(barIndex + 1),
                                y: screenHeight * 0.85
                            )
                            .opacity(0.6 + audioIntensity * 0.4)
                    }
                }
                
                // Particles floating around
                if isPlaying {
                    ForEach(0..<12, id: \.self) { particleIndex in
                        let particleSize = max(4, 4 + audioIntensity * 6)
                        let radiusX = min(screenWidth * 0.3, screenWidth / 2 - particleSize)
                        let radiusY = min(screenHeight * 0.2, screenHeight / 2 - particleSize)
                        
                        let particleX = max(particleSize, min(screenWidth - particleSize, 
                            centerX + cos(animationPhase * 2 + CGFloat(particleIndex) * .pi / 6) * radiusX))
                        let particleY = max(particleSize, min(screenHeight - particleSize,
                            centerY + sin(animationPhase * 1.5 + CGFloat(particleIndex) * .pi / 6) * radiusY))
                        
                        Circle()
                            .fill(primaryColor.opacity(0.4 + audioIntensity * 0.3))
                            .frame(width: particleSize, height: particleSize)
                            .position(x: particleX, y: particleY)
                            .opacity(0.5 + audioIntensity * 0.5)
                    }
                }
            }
        }
        .onReceive(animationTimer) { _ in
            if isAnimating {
                withAnimation(.linear(duration: 0.016)) {
                    animationPhase += 0.05
                    if animationPhase > 2 * .pi {
                        animationPhase = 0
                    }
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
    }
    
    func stopAnimation() {
        isAnimating = false
        animationPhase = 0
    }
}

#Preview {
    FullScreenWaveView(
        bpm: 140,
        primaryColor: .cyan,
        isPlaying: true,
        audioIntensity: 0.8
    )
    .background(Color.black)
}
