//
//  SimpleCircularVisualizer.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct SimpleCircularVisualizer: View {
    @State private var animationPhase: CGFloat = 0
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    let bpm: Double
    let radius: CGFloat
    let primaryColor: Color
    let numberOfBars: Int = 48 // Increased for smoother appearance
    
    private let animationTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // 60fps
    
    init(
        bpm: Double = 140,
        radius: CGFloat = 80,
        primaryColor: Color = .white
    ) {
        self.bpm = bpm
        self.radius = radius
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        ZStack {
            // Animated bars in a circle with enhanced positioning
            ForEach(0..<numberOfBars, id: \.self) { index in
                VisualizerBar(
                    index: index,
                    totalBars: numberOfBars,
                    radius: radius,
                    color: primaryColor,
                    animationPhase: animationPhase,
                    bpm: bpm
                )
            }
        }
        .frame(width: radius * 2, height: radius * 2)
        .clipped()
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

struct VisualizerBar: View {
    let index: Int
    let totalBars: Int
    let radius: CGFloat
    let color: Color
    let animationPhase: CGFloat
    let bpm: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(barOpacity),
                        color.opacity(barOpacity * 0.7),
                        color.opacity(barOpacity * 0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 2.5, height: barHeight)
            .position(barPosition)
            .rotationEffect(.radians(barRotation))
            .scaleEffect(barScale)
            .blur(radius: barBlur)
    }
    
    private var barPosition: CGPoint {
        let angle = (CGFloat(index) / CGFloat(totalBars)) * 2 * .pi
        // Use base radius for positioning, apply subtle variation separately
        let baseRadius = radius * 0.8 // Keep bars closer to center
        let radiusVariation = sin(animationPhase * 2 + angle) * 3
        let finalRadius = baseRadius + radiusVariation
        
        // Center the bars around the center point (radius, radius)
        let x = radius + cos(angle) * finalRadius
        let y = radius + sin(angle) * finalRadius
        return CGPoint(x: x, y: y)
    }
    
    private var barRotation: CGFloat {
        (CGFloat(index) / CGFloat(totalBars)) * 2 * .pi + .pi / 2
    }
    
    private var barHeight: CGFloat {
        let normalizedIndex = CGFloat(index) / CGFloat(totalBars)
        let phase = normalizedIndex * 2 * .pi + animationPhase
        
        // Create wave pattern synchronized with BPM
        let bpmPhase = animationPhase * CGFloat(bpm / 60.0)
        let pulse = sin(bpmPhase) * 0.5 + 0.5
        
        // Enhanced wave pattern with multiple frequencies
        let waveHeight = (sin(phase * 2) + sin(phase * 4) * 0.5 + sin(phase * 6) * 0.25) * pulse
        let baseHeight = 12.0
        let dynamicHeight = waveHeight * 25
        
        return max(baseHeight, baseHeight + dynamicHeight)
    }
    
    private var barOpacity: Double {
        let normalizedIndex = CGFloat(index) / CGFloat(totalBars)
        let phase = normalizedIndex * 2 * .pi + animationPhase
        let intensity = (sin(phase * 2) + 1) / 2
        
        // Add BPM-based pulsing
        let bpmPhase = animationPhase * CGFloat(bpm / 60.0)
        let bpmPulse = sin(bpmPhase) * 0.3 + 0.7
        
        return (0.4 + intensity * 0.6) * bpmPulse
    }
    
    private var barScale: CGFloat {
        let normalizedIndex = CGFloat(index) / CGFloat(totalBars)
        let phase = normalizedIndex * 2 * .pi + animationPhase
        let scaleVariation = sin(phase * 3) * 0.2 + 1.0
        return scaleVariation
    }
    
    private var barBlur: CGFloat {
        let normalizedIndex = CGFloat(index) / CGFloat(totalBars)
        let phase = normalizedIndex * 2 * .pi + animationPhase
        let blurVariation = sin(phase * 2) * 0.3
        return max(0, blurVariation)
    }
}



#Preview {
    SimpleCircularVisualizer(bpm: 140, radius: 100, primaryColor: .cyan)
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.black)
}
