//
//  CustomBPMView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct CustomBPMView: View {
    @Binding var customBPM: Int
    @Binding var selectedOption: BPMOption
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ? 
                                      [Color.black, Color.gray.opacity(0.3)] : 
                                      [Color.white, Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        
                        Text("Custom BPM")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("Set your perfect running tempo")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // BPM Display
                    VStack(spacing: 10) {
                        Text("\(customBPM)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                        
                        Text("BPM")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    // Slider
                    VStack(spacing: 20) {
                        HStack {
                            Text("60")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("200")
                                .foregroundColor(.gray)
                        }
                        .font(.caption)
                        
                        Slider(
                            value: Binding(
                                get: { Double(customBPM) },
                                set: { customBPM = Int($0) }
                            ),
                            in: 60...200,
                            step: 1
                        )
                        .accentColor(.purple)
                    }
                    .padding(.horizontal, 20)
                    
                    // BPM Range Guide
                    VStack(spacing: 15) {
                        Text("BPM Guide")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        VStack(spacing: 8) {
                            BPMGuideRow(range: "60-100", description: "Walking", color: .green)
                            BPMGuideRow(range: "100-140", description: "Easy Jog", color: .blue)
                            BPMGuideRow(range: "140-160", description: "Moderate Run", color: .orange)
                            BPMGuideRow(range: "160-180", description: "Fast Run", color: .red)
                            BPMGuideRow(range: "180+", description: "Sprint", color: .purple)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Apply Button
                    Button(action: {
                        selectedOption = BPMOption.custom(bpm: customBPM)
                        audioManager.setBPM(customBPM)
                        dismiss()
                    }) {
                        Text("Apply")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.purple)
                            )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
}

struct BPMGuideRow: View {
    let range: String
    let description: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(range)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

#Preview {
    CustomBPMView(
        customBPM: .constant(150),
        selectedOption: .constant(BPMOption.options[0])
    )
    .environmentObject(AudioManager())
}
