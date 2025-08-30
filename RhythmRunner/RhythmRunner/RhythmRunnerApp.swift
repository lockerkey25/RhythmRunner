//
//  RhythmRunnerApp.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI
import CoreData

@main
struct RhythmRunnerApp: App {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var spotifyManager = SpotifyManager()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var networkManager = NetworkManager()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(audioManager)
                .environmentObject(spotifyManager)
                .environmentObject(workoutManager)
                .environmentObject(networkManager)
                .onOpenURL { url in
                    handleSpotifyCallback(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Pause audio when app goes to background
                    audioManager.stopMetronome()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Resume audio session when app becomes active
                    audioManager.resetAudioSession()
                }
        }
    }
    
    private func handleSpotifyCallback(_ url: URL) {
        // Handle Spotify authentication callback
        print("Received URL: \(url.absoluteString)")
        
        // Check if this is a Spotify callback
        if url.scheme == "rhythmrunner" && url.host == "spotify-callback" {
            // The SpotifyAuthService will handle this through ASWebAuthenticationSession
            // This is just for logging/debugging
            print("Spotify callback received")
        }
    }
}
