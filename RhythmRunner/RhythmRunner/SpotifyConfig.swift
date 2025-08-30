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
    
    // Scopes needed for the app
    static let scopes: Set<String> = [
        "user-read-playback-state",
        "user-modify-playback-state", 
        "user-read-currently-playing",
        "streaming",
        "playlist-read-private",
        "playlist-read-collaborative",
        "user-library-read"
    ]
    
    // API Base URLs
    static let spotifyAPIBaseURL = "https://api.spotify.com/v1"
    static let spotifyAccountsBaseURL = "https://accounts.spotify.com"
}

// MARK: - API Endpoints
extension SpotifyConfig {
    static let searchEndpoint = "/search"
    static let audioFeaturesEndpoint = "/audio-features"
    static let tracksEndpoint = "/tracks"
    static let mePlayerEndpoint = "/me/player"
    static let mePlayerPlayEndpoint = "/me/player/play"
    static let mePlayerPauseEndpoint = "/me/player/pause"
}
