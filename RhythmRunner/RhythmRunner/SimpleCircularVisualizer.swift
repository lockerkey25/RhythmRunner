//
//  SimpleCircularVisualizer.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI
import AVFoundation

struct SimpleCircularVisualizer: View {
    @State private var animationPhase: CGFloat = 0
    @State private var isAnimating = false
    @State private var audioLevel: CGFloat = 0.0
    @State private var beatPulse: CGFloat = 0.0
    @Environment(\.colorScheme) var colorScheme
    
    let bpm: Double
    let radius: CGFloat
    let primaryColor: Color
    let isPlaying: Bool
    let audioIntensity: CGFloat // 0.0 to 1.0 for audio visualization
    
    private let animationTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // 60fps
    
    init(
        bpm: Double = 140,
        radius: CGFloat = 80,
        primaryColor: Color = .white,
        isPlaying: Bool = false,
        audioIntensity: CGFloat = 0.0
    ) {
        self.bpm = bpm
        self.radius = radius
        self.primaryColor = primaryColor
        self.isPlaying = isPlaying
        self.audioIntensity = audioIntensity
    }
    
    var body: some View {
        ZStack {
            // Main animated circle with audio-responsive pulsing
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            primaryColor.opacity(0.8 + audioIntensity * 0.2),
                            primaryColor.opacity(0.4 + audioIntensity * 0.3),
                            primaryColor.opacity(0.1 + audioIntensity * 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3 + audioIntensity * 2
                )
                .scaleEffect(1.0 + Foundation.sin(animationPhase * 2) * 0.1 + audioIntensity * 0.15)
                .opacity(0.8 + Foundation.sin(animationPhase * 3) * 0.2 + audioIntensity * 0.2)
            
            // Inner pulse circle that responds to audio
            Circle()
                .stroke(
                    primaryColor.opacity(0.3 + audioIntensity * 0.4),
                    lineWidth: 1 + audioIntensity * 1.5
                )
                .scaleEffect(0.7 + Foundation.sin(animationPhase * 4) * 0.05 + audioIntensity * 0.1)
                .opacity(0.6 + Foundation.sin(animationPhase * 2) * 0.3 + audioIntensity * 0.3)
            
            // Beat-responsive outer ring
            if isPlaying {
                Circle()
                    .stroke(
                        primaryColor.opacity(0.6),
                        lineWidth: 2
                    )
                    .scaleEffect(1.2 + beatPulse * 0.3)
                    .opacity(beatPulse)
            }
            
            // Audio level bars around the circle (when playing)
            if isPlaying && audioIntensity > 0.1 {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(primaryColor.opacity(0.7))
                        .frame(width: 2, height: 8 + audioIntensity * 20)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .offset(y: -radius - 15)
                        .opacity(0.5 + audioIntensity * 0.5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(animationTimer) { _ in
            if isAnimating {
                withAnimation(.linear(duration: 0.016)) {
                    animationPhase += 0.03
                    if animationPhase > 2 * .pi {
                        animationPhase = 0
                    }
                    
                    // Beat pulse synchronized with BPM
                    if isPlaying {
                        let beatInterval = 60.0 / bpm
                        let beatPhase = (CACurrentMediaTime() * 2 * .pi) / beatInterval
                        beatPulse = Foundation.sin(beatPhase) * 0.5 + 0.5
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
        beatPulse = 0
    }
}

#Preview {
    SimpleCircularVisualizer(
        bpm: 140, 
        radius: 100, 
        primaryColor: .cyan,
        isPlaying: true,
        audioIntensity: 0.7
    )
    .frame(width: 200, height: 200)
    .padding()
    .background(Color.black)
}
