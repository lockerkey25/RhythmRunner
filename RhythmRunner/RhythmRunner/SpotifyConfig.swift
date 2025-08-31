//
//  SpotifyConfig.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation

struct SpotifyConfig {
    // Get this from https://developer.spotify.com/dashboard/applications
    static let clientID = "d7e5f031eada4138a55b47d737db9d5a"
    
    // Redirect URI - must match what's configured in your Spotify app
    static let redirectURI = "rhythmrunner://spotify-callback"
    
    // Enhanced scopes needed for the app
    static let scopes: Set<String> = [
        "user-read-playback-state",
        "user-modify-playback-state", 
        "user-read-currently-playing",
        "streaming",
        "playlist-read-private",
        "playlist-read-collaborative",
        "user-library-read",
        "user-read-email",
        "user-read-private"
    ]
    
    // API Base URLs
    static let spotifyAPIBaseURL = "https://api.spotify.com/v1"
    static let spotifyAccountsBaseURL = "https://accounts.spotify.com"
    
    // Enhanced error messages
    static let errorMessages = [
        "network_error": "Network connection issue. Please check your internet and try again.",
        "auth_failed": "Authentication failed. Please try logging in again.",
        "premium_required": "Spotify Premium is required for full playback control.",
        "device_not_found": "No active Spotify device found. Please open Spotify app first.",
        "playback_error": "Playback error. Please try a different song or restart Spotify."
    ]
}

// MARK: - API Endpoints
extension SpotifyConfig {
    static let searchEndpoint = "/search"
    static let audioFeaturesEndpoint = "/audio-features"
    static let tracksEndpoint = "/tracks"
    static let mePlayerEndpoint = "/me/player"
    static let mePlayerPlayEndpoint = "/me/player/play"
    static let mePlayerPauseEndpoint = "/me/player/pause"
    static let meEndpoint = "/me"
    static let devicesEndpoint = "/me/player/devices"
}
