//
//  RunningSessionView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct RunningSessionView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var networkMonitor = NetworkMonitor()
    
    let selectedBPM: Int
    let sessionType: SessionType
    let selectedDuration: RunningDuration?
    
    @State private var showingEndSessionAlert = false
    @State private var animateComponents = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with session info
                        sessionHeaderSection
                            .opacity(animateComponents ? 1 : 0)
                            .offset(y: animateComponents ? 0 : -20)
                            .animation(.easeOut(duration: 0.5), value: animateComponents)
                        
                        // Main timer display
                        mainTimerSection
                            .opacity(animateComponents ? 1 : 0)
                            .scaleEffect(animateComponents ? 1 : 0.8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animateComponents)
                        
                        // Circular waveform visualization
                        waveformSection
                            .opacity(animateComponents ? 1 : 0)
                            .scaleEffect(animateComponents ? 1 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateComponents)
                        
                        // BPM and controls
                        controlsSection
                            .opacity(animateComponents ? 1 : 0)
                            .offset(y: animateComponents ? 0 : 20)
                            .animation(.easeOut(duration: 0.5), value: animateComponents)
                        
                        // Current song display
                        if let currentSong = spotifyManager.currentSong {
                            currentSongSection(song: currentSong)
                                .opacity(animateComponents ? 1 : 0)
                                .offset(y: animateComponents ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(0.5), value: animateComponents)
                        }
                        
                        // Session stats
                        sessionStatsSection
                            .opacity(animateComponents ? 1 : 0)
                            .offset(y: animateComponents ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: animateComponents)
                        
                        // Network status (if needed)
                        if !networkMonitor.isConnected || networkMonitor.shouldShowDataWarning() {
                            networkStatusSection
                                .opacity(animateComponents ? 1 : 0)
                                .animation(.easeOut(duration: 0.4).delay(0.7), value: animateComponents)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Floating end session button
                VStack {
                    Spacer()
                    endSessionButton
                        .padding(.bottom, 30)
                        .opacity(animateComponents ? 1 : 0)
                        .offset(y: animateComponents ? 0 : 50)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.8), value: animateComponents)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation {
                animateComponents = true
            }
        }
        .alert("End Session", isPresented: $showingEndSessionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                endSession()
            }
        } message: {
            Text("Are you sure you want to end your running session?")
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ? 
                              [Color.black, Color.purple.opacity(0.4), Color.blue.opacity(0.3), Color.black] : 
                              [Color.white, Color.blue.opacity(0.2), Color.purple.opacity(0.15), Color.white]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Session Header
    private var sessionHeaderSection: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    showingEndSessionAlert = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                                .overlay(
                                    Circle()
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
                
                Text("Running Session")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                // Session type indicator
                HStack(spacing: 8) {
                    Image(systemName: sessionType == .timed ? "timer" : "infinity")
                        .foregroundColor(.cyan)
                    
                    Text(sessionType == .timed ? "Timed" : "Free Run")
                        .font(.caption)
                        .foregroundColor(.cyan)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.cyan.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            
            if sessionType == .timed, let duration = selectedDuration {
                HStack {
                    Text("Target: \(duration.displayText)")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    
                    Spacer()
                    
                    Text("Progress: \(workoutManager.completionPercentage, specifier: "%.0f")%")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Main Timer
    private var mainTimerSection: some View {
        VStack(spacing: 18) {
            Text(workoutManager.isTimedSession ? "Time Remaining" : "Session Duration")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .white.opacity(0.3), radius: 1, x: 0, y: 1)
            
            HStack(spacing: 8) {
                Text(workoutManager.isTimedSession ? workoutManager.formattedTimeRemaining : workoutManager.formattedDuration)
                    .font(.system(size: 58, weight: .bold, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4), radius: 15, x: 0, y: 0)
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark ? [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.02),
                                Color.clear
                            ] : [
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: colorScheme == .dark ? [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ] : [
                                        Color.black.opacity(0.4),
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.2), radius: 25, x: 0, y: 12)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.1) : .white.opacity(0.05), radius: 15, x: 0, y: 8)
                )
        }
    }
    
    // MARK: - Waveform Section
    private var waveformSection: some View {
        VStack(spacing: 25) {
            Text("Rhythm Visualization")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .white.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Simplified, clean waveform visualization
            SimpleCircularVisualizer(
                bpm: Double(selectedBPM),
                radius: 100,
                primaryColor: colorScheme == .dark ? .cyan : .blue
            )
            .frame(width: 240, height: 240)
            .shadow(color: colorScheme == .dark ? .cyan.opacity(0.3) : .blue.opacity(0.3), radius: 15, x: 0, y: 8)
            .clipped()
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Controls Section
    private var controlsSection: some View {
        VStack(spacing: 20) {
            // BPM Display
            VStack(spacing: 5) {
                Text("\(selectedBPM)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                    .shadow(color: colorScheme == .dark ? .cyan.opacity(0.5) : .blue.opacity(0.5), radius: 10, x: 0, y: 0)
                
                Text("BPM")
                    .font(.title3)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            }
            
            // Metronome Toggle
            HStack {
                Image(systemName: audioManager.metronomeEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Metronome")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Toggle("", isOn: $audioManager.metronomeEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: colorScheme == .dark ? .cyan : .blue))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Current Song Section
    private func currentSongSection(song: Song) -> some View {
        VStack(spacing: 15) {
            Text("Now Playing")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            
            VStack(spacing: 12) {
                Text(song.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                
                Text("\(song.bpm) BPM")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.cyan.opacity(0.2) : Color.blue.opacity(0.2))
                    )
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Session Stats
    private var sessionStatsSection: some View {
        VStack(spacing: 15) {
            Text("Session Stats")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(
                    title: "Songs Played",
                    value: "\(workoutManager.songsPlayedCount)",
                    icon: "music.note",
                    color: .green
                )
                
                StatCard(
                    title: "Avg BPM",
                    value: "\(selectedBPM)",
                    icon: "heart.fill",
                    color: .red
                )
                
                if sessionType == .timed, let _ = selectedDuration {
                    StatCard(
                        title: "Completion",
                        value: "\(Int(workoutManager.completionPercentage))%",
                        icon: "target",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Remaining",
                        value: workoutManager.formattedTimeRemaining,
                        icon: "clock",
                        color: .blue
                    )
                }
            }
        }
    }
    
    // MARK: - Network Status
    private var networkStatusSection: some View {
        HStack {
            Image(systemName: networkMonitor.isConnected ? "wifi.exclamationmark" : "wifi.slash")
                .foregroundColor(networkMonitor.isConnected ? .orange : .red)
            
            Text(networkMonitor.getNetworkStatus())
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            
            Spacer()
            
            Image(systemName: networkMonitor.connectionType.icon)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .font(.caption)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.red.opacity(0.1) : Color.red.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - End Session Button
    private var endSessionButton: some View {
        Button(action: {
            showingEndSessionAlert = true
        }) {
            HStack(spacing: 15) {
                Image(systemName: "stop.fill")
                    .font(.title2)
                
                Text("End Session")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 10)
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Actions
    private func endSession() {
        audioManager.stopMetronome()
        spotifyManager.stopPlayback()
        workoutManager.stopWorkout()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RunningSessionView(
        selectedBPM: 140,
        sessionType: .timed,
        selectedDuration: .thirtyMinutes
    )
    .environmentObject(AudioManager())
    .environmentObject(SpotifyManager())
    .environmentObject(WorkoutManager())
}

