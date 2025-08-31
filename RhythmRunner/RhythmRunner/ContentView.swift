//
//  ContentView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var selectedBPMOption: BPMOption = BPMOption.options[1] // Default to 140 BPM
    @State private var showingCustomBPM = false
    @State private var customBPM = 150
    @State private var showingSongList = false
    @State private var selectedSessionType: SessionType = .freeRun
    @State private var selectedDuration: RunningDuration?
    @State private var showingSessionTypeSelection = false
    @State private var isHeaderVisible = false
    @State private var contentOffset: CGFloat = 50
    @State private var showingRunningSession = false
    
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
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with refined spacing
                        headerSection
                            .opacity(isHeaderVisible ? 1.0 : 0.0)
                            .offset(y: isHeaderVisible ? 0 : -20)
                            .animation(.easeOut(duration: 0.8).delay(0.1), value: isHeaderVisible)
                            .padding(.bottom, 32)
                        
                        // Session Type Selection (before workout starts)
                        if !workoutManager.isWorkoutActive {
                            sessionTypeSection
                                .opacity(isHeaderVisible ? 1.0 : 0.0)
                                .offset(y: isHeaderVisible ? 0 : contentOffset)
                                .animation(.easeOut(duration: 0.8).delay(0.3), value: isHeaderVisible)
                                .padding(.bottom, 28)
                        }
                        
                        // BPM Selection
                        bpmSelectionSection
                            .opacity(isHeaderVisible ? 1.0 : 0.0)
                            .offset(y: isHeaderVisible ? 0 : contentOffset)
                            .animation(.easeOut(duration: 0.8).delay(0.5), value: isHeaderVisible)
                            .padding(.bottom, 32)
                        
                        // Timer Display (when workout is active)
                        if workoutManager.isWorkoutActive {
                            timerSection
                                .opacity(1.0)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.6, dampingFraction: 0.8)),
                                    removal: .opacity.animation(.easeOut(duration: 0.3))
                                ))
                                .padding(.bottom, 28)
                        }
                        
                        // Controls
                        controlsSection
                            .opacity(isHeaderVisible ? 1.0 : 0.0)
                            .offset(y: isHeaderVisible ? 0 : contentOffset)
                            .animation(.easeOut(duration: 0.8).delay(0.7), value: isHeaderVisible)
                            .padding(.bottom, 24)
                        
                        // Current Song Display
                        if let currentSong = spotifyManager.currentSong {
                            currentSongSection(song: currentSong)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity).animation(.spring(response: 0.6, dampingFraction: 0.8)),
                                    removal: .move(edge: .bottom).combined(with: .opacity).animation(.easeOut(duration: 0.3))
                                ))
                                .padding(.bottom, 20)
                        }
                        
                        // Spotify Connection
                        spotifyConnectionSection
                            .opacity(isHeaderVisible ? 1.0 : 0.0)
                            .offset(y: isHeaderVisible ? 0 : contentOffset)
                            .animation(.easeOut(duration: 0.8).delay(0.9), value: isHeaderVisible)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCustomBPM) {
            CustomBPMView(customBPM: $customBPM, selectedOption: $selectedBPMOption)
        }
        .sheet(isPresented: $showingSongList) {
            SongListView(bpm: selectedBPMOption.bpm)
        }
        .sheet(isPresented: $showingSessionTypeSelection) {
            SessionTypeView(selectedSessionType: $selectedSessionType, selectedDuration: $selectedDuration)
        }
        .fullScreenCover(isPresented: $showingRunningSession) {
            RunningSessionView(
                selectedBPM: selectedBPMOption.bpm,
                sessionType: selectedSessionType,
                selectedDuration: selectedDuration
            )
            .environmentObject(audioManager)
            .environmentObject(spotifyManager)
            .environmentObject(workoutManager)
        }
        .onAppear {
            withAnimation {
                isHeaderVisible = true
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("RhythmRunner")
                .font(.custom("SF Pro Display", size: 48, relativeTo: .largeTitle))
                .fontWeight(.black)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .shadow(color: selectedBPMOption.color.opacity(0.3), radius: 10, x: 0, y: 5)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text("Run to the Beat")
                .font(.custom("SF Pro Text", size: 24, relativeTo: .largeTitle))
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    private var sessionTypeSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Session Type")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Button("Change") {
                    showingSessionTypeSelection = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 15) {
                // Session Type Display
                HStack {
                    Image(systemName: selectedSessionType == .timed ? "timer" : "infinity")
                        .font(.title2)
                        .foregroundColor(selectedSessionType == .timed ? .blue : .green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedSessionType == .timed ? "Timed Session" : "Free Run")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        if selectedSessionType == .timed, let duration = selectedDuration {
                            Text(duration.displayText + " • " + duration.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Run for as long as you want")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            }
        }
    }
    
    private var timerSection: some View {
        VStack(spacing: 15) {
            Text(workoutManager.isTimedSession ? "Time Remaining" : "Workout Timer")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(workoutManager.isTimedSession ? workoutManager.formattedTimeRemaining : workoutManager.formattedDuration)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(workoutManager.isTimedSession ? .orange : (colorScheme == .dark ? .white : .black))
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(workoutManager.isTimedSession ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(workoutManager.isTimedSession ? Color.orange.opacity(0.5) : Color.green.opacity(0.5), lineWidth: 2)
                        )
                )
            
            Text(workoutManager.isTimedSession ? "Countdown Active" : "Session Active")
                .font(.caption)
                .foregroundColor(workoutManager.isTimedSession ? .orange : .green)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(workoutManager.isTimedSession ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                )
        }
    }
    
    private var bpmSelectionSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Tempo")
                .font(.custom("SF Pro Display", size: 28, relativeTo: .title2))
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            // Enhanced BPM Grid with better spacing and visual hierarchy
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 20) {
                ForEach(BPMOption.options) { option in
                    BPMOptionCard(
                        option: option,
                        isSelected: selectedBPMOption.id == option.id,
                        action: {
                            selectedBPMOption = option
                            audioManager.setBPM(option.bpm)
                        },
                        onDoubleTap: {
                            // Select the BPM first
                            selectedBPMOption = option
                            audioManager.setBPM(option.bpm)
                            
                            // Start the session automatically
                            startSessionWithDoubleTap()
                        }
                    )
                }
                
                // Custom BPM option with enhanced styling
                Button(action: {
                    showingCustomBPM = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title)
                            .foregroundColor(.purple)
                            .scaleEffect(1.1)
                        
                        Text("Custom")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text("Set your own BPM")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.purple, Color.purple.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    private var controlsSection: some View {
        VStack(spacing: 25) {
            // Session status indicator (removed duplicate visualizer)
            if workoutManager.isWorkoutActive {
                VStack(spacing: 18) {
                    Text("Session Active")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text("\(selectedBPMOption.bpm) BPM")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedBPMOption.color)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedBPMOption.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Enhanced BPM Display with better visual hierarchy
            VStack(spacing: 8) {
                Text("\(selectedBPMOption.bpm)")
                    .font(.custom("SF Pro Display", size: 52, relativeTo: .largeTitle))
                    .foregroundColor(selectedBPMOption.color)
                    .shadow(color: selectedBPMOption.color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Text("BPM")
                    .font(.custom("SF Pro Text", size: 20, relativeTo: .title3))
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 10)
            
            // Enhanced Play/Stop Button with better styling
            Button(action: {
                if workoutManager.isWorkoutActive {
                    audioManager.stopMetronome()
                    spotifyManager.stopPlayback()
                    workoutManager.stopWorkout()
                } else {
                    // Validate timed session has duration selected
                    if selectedSessionType == .timed && selectedDuration == nil {
                        showingSessionTypeSelection = true
                        return
                    }
                    
                    // Start the workout
                    audioManager.startMetronome()
                    workoutManager.startWorkout(
                        targetBPM: selectedBPMOption.bpm,
                        sessionType: selectedSessionType,
                        duration: selectedDuration
                    )
                    
                    // Auto-play a song if available
                    if let song = spotifyManager.getRandomSongForBPM(selectedBPMOption.bpm) {
                        spotifyManager.playSong(song)
                        workoutManager.addSongToSession(song.title)
                    }
                    
                    // Navigate to running session view
                    showingRunningSession = true
                }
            }) {
                HStack(spacing: 18) {
                    Image(systemName: workoutManager.isWorkoutActive ? "stop.fill" : "play.fill")
                        .font(.title2)
                        .scaleEffect(1.1)
                    
                    Text(workoutManager.isWorkoutActive ? "End Session" : "Start Workout")
                        .font(.custom("SF Pro Display", size: 20, relativeTo: .headline))
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: workoutManager.isWorkoutActive ? 
                                    [Color.red, Color.red.opacity(0.8)] : 
                                    [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: workoutManager.isWorkoutActive ? Color.red.opacity(0.4) : Color.green.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
            }
            .scaleEffect(workoutManager.isWorkoutActive ? 1.0 : 1.02)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: workoutManager.isWorkoutActive)
            
            // Enhanced Metronome Toggle with better styling
            HStack(spacing: 15) {
                Image(systemName: "speaker.wave.2")
                    .font(.title3)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Metronome")
                    .font(.custom("SF Pro Text", size: 16, relativeTo: .subheadline))
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Toggle("", isOn: $audioManager.metronomeEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .scaleEffect(1.1)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark ? 
                                [Color.white.opacity(0.12), Color.white.opacity(0.08)] : 
                                [Color.black.opacity(0.06), Color.black.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    private func currentSongSection(song: Song) -> some View {
        VStack(spacing: 15) {
            Text("Now Playing")
                .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(song.title)
                    .font(.custom("SF Pro Display", size: 20, relativeTo: .title3))
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                
                Text(song.artist)
                    .font(.custom("SF Pro Text", size: 16, relativeTo: .subheadline))
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text("\(song.bpm) BPM")
                    .font(.custom("SF Pro Text", size: 12, relativeTo: .caption))
                    .fontWeight(.semibold)
                    .foregroundColor(selectedBPMOption.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(selectedBPMOption.color.opacity(0.2))
                    )
            }
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
            )
        }
    }
    
    private var spotifyConnectionSection: some View {
        VStack(spacing: 15) {
            if spotifyManager.isConnected {
                // Connected state - show browse songs button
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        Text("Spotify Connected")
                            .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                        
                        Button("Disconnect") {
                            spotifyManager.disconnect()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    Button(action: {
                        showingSongList = true
                    }) {
                        HStack {
                            Image(systemName: "music.note.list")
                                .foregroundColor(.blue)
                            
                            Text("Browse Songs")
                                .font(.custom("SF Pro Text", size: 16, relativeTo: .subheadline))
                                .fontWeight(.semibold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                            
                            if !spotifyManager.recommendedSongs.isEmpty {
                                Text("\(spotifyManager.recommendedSongs.count) songs")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        )
                    }
                    
                    // Current song display if playing
                    if let currentSong = spotifyManager.currentSong {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currentSong.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .lineLimit(1)
                                
                                Text("\(currentSong.artist) • \(currentSong.bpm) BPM")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button("Stop") {
                                spotifyManager.stopPlayback()
                            }
                            .font(.caption2)
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            } else {
                // Not connected state
                VStack(spacing: 12) {
                    // Error message display
                    if let errorMessage = spotifyManager.errorMessage {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("Connection Error")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Spacer()
                            }
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Network status indicator
                    if !networkMonitor.isConnected || networkMonitor.shouldShowDataWarning() {
                        HStack {
                            Image(systemName: networkMonitor.isConnected ? "wifi.exclamationmark" : "wifi.slash")
                                .foregroundColor(networkMonitor.isConnected ? .orange : .red)
                            
                            Text(networkMonitor.getNetworkStatus())
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Image(systemName: networkMonitor.connectionType.icon)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(networkMonitor.isConnected ? Color.orange.opacity(0.1) : Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(networkMonitor.isConnected ? Color.orange.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Connect button
                    Button(action: {
                        spotifyManager.connectToSpotify()
                    }) {
                        HStack {
                            if spotifyManager.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            } else {
                                Image(systemName: "music.note")
                                    .foregroundColor(.green)
                            }
                            
                            Text(spotifyManager.isLoading ? "Connecting..." : "Connect Spotify")
                                .font(.custom("SF Pro Display", size: 18, relativeTo: .headline))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !spotifyManager.isLoading {
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                        )
                    }
                    .disabled(spotifyManager.isLoading || !networkMonitor.isConnected)
                    
                    // Info text
                    VStack(spacing: 8) {
                        Text("Connect to Spotify to access millions of songs with BPM matching for your workout.")
                            .font(.custom("SF Pro Text", size: 12, relativeTo: .caption))
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        
                        if spotifyManager.errorMessage != nil {
                            VStack(spacing: 4) {
                                Text("Troubleshooting Tips:")
                                    .font(.custom("SF Pro Text", size: 10, relativeTo: .caption2))
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                
                                Text("• Make sure you have Spotify Premium")
                                    .font(.custom("SF Pro Text", size: 10, relativeTo: .caption2))
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Text("• Check your internet connection")
                                    .font(.custom("SF Pro Text", size: 10, relativeTo: .caption2))
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Text("• Try logging out and back into Spotify")
                                    .font(.custom("SF Pro Text", size: 10, relativeTo: .caption2))
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                            }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func startSessionWithDoubleTap() {
        // For timed sessions, use default duration if none selected
        if selectedSessionType == .timed && selectedDuration == nil {
            selectedDuration = .fifteenMinutes // Default to 15 minutes
        }
        
        // Start the workout
        audioManager.startMetronome()
        workoutManager.startWorkout(
            targetBPM: selectedBPMOption.bpm,
            sessionType: selectedSessionType,
            duration: selectedDuration
        )
        
        // Auto-play a song if available
        if let song = spotifyManager.getRandomSongForBPM(selectedBPMOption.bpm) {
            spotifyManager.playSong(song)
            workoutManager.addSongToSession(song.title)
        }
        
        // Navigate to running session view
        showingRunningSession = true
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioManager())
        .environmentObject(SpotifyManager())
        .environmentObject(WorkoutManager())
}
