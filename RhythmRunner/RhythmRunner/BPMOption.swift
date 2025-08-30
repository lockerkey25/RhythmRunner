//
//  BPMOption.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct BPMOption: Identifiable, Hashable {
    let id = UUID()
    let bpm: Int
    let name: String
    let description: String
    let icon: String
    let color: Color
    
    static let options: [BPMOption] = [
        BPMOption(
            bpm: 120,
            name: "Easy Jog",
            description: "Perfect for warm-up, cool-down, or recovery runs",
            icon: "figure.walk",
            color: .green
        ),
        BPMOption(
            bpm: 140,
            name: "Moderate Run",
            description: "Ideal for steady-state cardio and endurance training",
            icon: "figure.run",
            color: .blue
        ),
        BPMOption(
            bpm: 160,
            name: "Fast Run",
            description: "Great for tempo runs and building speed",
            icon: "figure.run.circle",
            color: .orange
        ),
        BPMOption(
            bpm: 180,
            name: "Sprint",
            description: "High-intensity intervals and speed work",
            icon: "bolt.fill",
            color: .red
        )
    ]
    
    static func custom(bpm: Int) -> BPMOption {
        BPMOption(
            bpm: bpm,
            name: "Custom \(bpm) BPM",
            description: "Custom tempo for your specific training needs",
            icon: "slider.horizontal.3",
            color: .purple
        )
    }
}
