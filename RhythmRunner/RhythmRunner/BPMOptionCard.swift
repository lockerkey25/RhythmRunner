//
//  BPMOptionCard.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct BPMOptionCard: View {
    let option: BPMOption
    let isSelected: Bool
    let action: () -> Void
    var onDoubleTap: (() -> Void)? = nil
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    @State private var showDoubleTapFeedback = false
    @State private var hoverScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }) {
            VStack(spacing: 12) {
                // Icon with enhanced pulse animation when selected
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        option.color.opacity(0.3),
                                        option.color.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 70, height: 70)
                            .scaleEffect(isSelected ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isSelected)
                    }
                    
                    Image(systemName: option.icon)
                        .font(.custom("SF Pro Display", size: 24, relativeTo: .title))
                        .foregroundColor(option.color)
                        .scaleEffect(isSelected ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
                }
                
                Text(option.name)
                    .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("\(option.bpm)")
                    .font(.custom("SF Pro Display", size: 26, relativeTo: .title))
                    .foregroundColor(option.color)
                    .shadow(color: option.color.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text("BPM")
                    .font(.custom("SF Pro Text", size: 12, relativeTo: .caption))
                    .foregroundColor(option.color)
                
                Text(option.description)
                    .font(.custom("SF Pro Text", size: 12, relativeTo: .caption))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .opacity(isSelected ? 1.0 : 0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [option.color.opacity(0.2), option.color.opacity(0.1)] :
                                (colorScheme == .dark ? 
                                    [Color.white.opacity(0.1), Color.white.opacity(0.05)] : 
                                    [Color.black.opacity(0.04), Color.black.opacity(0.02)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: isSelected ? 
                                        [option.color, option.color.opacity(0.7)] : 
                                        [Color.clear, Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2.5 : 0
                            )
                            .shadow(
                                color: isSelected ? option.color.opacity(0.4) : Color.clear,
                                radius: isSelected ? 12 : 0,
                                x: 0,
                                y: isSelected ? 6 : 0
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : hoverScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: hoverScale)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    // Double-tap action
                    if let doubleTapAction = onDoubleTap {
                        // Strong haptic feedback for double-tap
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                        
                        // Visual feedback
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showDoubleTapFeedback = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showDoubleTapFeedback = false
                            }
                        }
                        
                        doubleTapAction()
                    }
                }
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                hoverScale = hovering ? 1.02 : 1.0
            }
        }
        .overlay(
            // Double-tap feedback overlay with enhanced styling
            showDoubleTapFeedback ? 
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                option.color.opacity(0.4),
                                option.color.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: showDoubleTapFeedback)
                
                VStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.custom("SF Pro Display", size: 20, relativeTo: .title2))
                        .foregroundColor(.white)
                    
                    Text("Starting Session")
                        .font(.custom("SF Pro Text", size: 12, relativeTo: .caption))
                        .foregroundColor(.white)
                }
                .scaleEffect(showDoubleTapFeedback ? 1.2 : 0.8)
                .opacity(showDoubleTapFeedback ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showDoubleTapFeedback)
            } : nil
        )
    }
    
    // Main initializer with double-tap support
    init(option: BPMOption, isSelected: Bool, action: @escaping () -> Void, onDoubleTap: (() -> Void)? = nil) {
        self.option = option
        self.isSelected = isSelected
        self.action = action
        self.onDoubleTap = onDoubleTap
    }
}

#Preview {
    HStack {
        BPMOptionCard(
            option: BPMOption.options[0],
            isSelected: true
        ) {}
        
        BPMOptionCard(
            option: BPMOption.options[1],
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.black)
}
