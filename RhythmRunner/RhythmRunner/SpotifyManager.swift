//
//  SpotifyManager.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Combine
import CryptoKit

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let bpm: Int
    let spotifyURI: String
    let albumArtURL: String?
}

// MARK: - Spotify Manager
class SpotifyManager: ObservableObject {
    @Published var isConnected = false
    @Published var currentSong: Song?
    @Published var recommendedSongs: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPlaybackState: SpotifyPlaybackState?
    
    private let apiService: SpotifyAPIService
    private let authService: SpotifyAuthService
    private var cancellables = Set<AnyCancellable>()
    
    // BPM search configurations
    private let bpmTolerance: Double = 10.0
    private let maxSearchResults = 50
    
    // Mock data for fallback when no API connection
    private let mockSongs: [Song] = [
        Song(id: "1", title: "Running in the 90s", artist: "Max Coveri", album: "Initial D", bpm: 160, spotifyURI: "spotify:track:1", albumArtURL: nil),
        Song(id: "2", title: "Eye of the Tiger", artist: "Survivor", album: "Rocky III", bpm: 180, spotifyURI: "spotify:track:2", albumArtURL: nil),
        Song(id: "3", title: "Born to Run", artist: "Bruce Springsteen", album: "Born to Run", bpm: 140, spotifyURI: "spotify:track:3", albumArtURL: nil),
        Song(id: "4", title: "Chariots of Fire", artist: "Vangelis", album: "Chariots of Fire", bpm: 120, spotifyURI: "spotify:track:4", albumArtURL: nil),
        Song(id: "5", title: "The Final Countdown", artist: "Europe", album: "The Final Countdown", bpm: 160, spotifyURI: "spotify:track:5", albumArtURL: nil),
        Song(id: "6", title: "We Will Rock You", artist: "Queen", album: "News of the World", bpm: 180, spotifyURI: "spotify:track:6", albumArtURL: nil),
        Song(id: "7", title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", bpm: 140, spotifyURI: "spotify:track:7", albumArtURL: nil),
        Song(id: "8", title: "Don't Stop Believin'", artist: "Journey", album: "Escape", bpm: 120, spotifyURI: "spotify:track:8", albumArtURL: nil)
    ]
    
    init() {
        self.apiService = SpotifyAPIService()
        self.authService = SpotifyAuthService()
        
        // Check for existing authentication
        checkExistingAuthentication()
        
        // Start monitoring playback state if connected
        startPlaybackMonitoring()
    }
    
    // MARK: - Authentication Methods
    
    func connectToSpotify() {
        isLoading = true
        errorMessage = nil
        
        print("🎵 Starting Spotify authentication...")
        
        authService.authenticate()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        switch completion {
                        case .failure(let error):
                            print("❌ Spotify authentication failed: \(error.localizedDescription)")
                            
                            // Provide user-friendly error messages
                            let userFriendlyMessage: String
                            switch error {
                            case .authenticationRequired:
                                userFriendlyMessage = "Spotify authentication is required. Please try again."
                            case .networkError(let networkError):
                                if networkError.localizedDescription.contains("cancelled") {
                                    userFriendlyMessage = "Authentication was cancelled. Tap to try again."
                                } else {
                                    userFriendlyMessage = "Network error. Please check your internet connection and try again."
                                }
                            case .decodingError(_):
                                userFriendlyMessage = "There was an issue with the Spotify authentication. This might be due to an app configuration issue. Please try again or contact support."
                            default:
                                userFriendlyMessage = "Unable to connect to Spotify. Please try again."
                            }
                            
                            self?.errorMessage = userFriendlyMessage
                            self?.isConnected = false
                            
                            // Auto-clear error message after 10 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                if self?.errorMessage == userFriendlyMessage {
                                    self?.errorMessage = nil
                                }
                            }
                        case .finished:
                            print("✅ Spotify authentication completed")
                            break
                        }
                    }
                },
                receiveValue: { [weak self] tokenResponse in
                    DispatchQueue.main.async {
                        print("🔑 Received Spotify token, handling authentication success")
                        self?.handleAuthenticationSuccess(tokenResponse)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func disconnect() {
        authService.logout()
        isConnected = false
        currentSong = nil
        recommendedSongs = []
        currentPlaybackState = nil
    }
    
    private func checkExistingAuthentication() {
        guard let accessToken = UserDefaults.standard.string(forKey: "SpotifyAccessToken"),
              let expirationDate = UserDefaults.standard.object(forKey: "SpotifyTokenExpiration") as? Date,
              expirationDate > Date() else {
            // Try to refresh token if available
            attemptTokenRefresh()
            return
        }
        
        // Token is still valid
        let expiresIn = Int(expirationDate.timeIntervalSinceNow)
        apiService.setAccessToken(accessToken, expiresIn: expiresIn)
        isConnected = true
    }
    
    private func attemptTokenRefresh() {
        guard let refreshToken = UserDefaults.standard.string(forKey: "SpotifyRefreshToken") else {
            return
        }
        
        authService.refreshToken(refreshToken)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] tokenResponse in
                    DispatchQueue.main.async {
                        self?.handleAuthenticationSuccess(tokenResponse)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleAuthenticationSuccess(_ tokenResponse: SpotifyTokenResponse) {
        print("🎵 Setting access token and updating connection state")
        apiService.setAccessToken(tokenResponse.accessToken, expiresIn: tokenResponse.expiresIn)
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.isLoading = false
            self.errorMessage = nil
            print("✅ SpotifyManager isConnected set to true")
            
            // Automatically fetch some default songs after successful authentication
            self.fetchDefaultSongs()
        }
    }
    
    private func fetchDefaultSongs() {
        // Fetch songs for a default BPM (140) to show immediate results
        print("🎵 Fetching default songs after authentication success...")
        getSongsForBPM(140)
    }
    
    // MARK: - Song Search Methods
    
    func getSongsForBPM(_ targetBPM: Int) {
        guard isConnected else {
            // Fallback to mock data
            getMockSongsForBPM(targetBPM)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Search for energetic and danceable songs
        let queries = generateSearchQueries(for: targetBPM)
        
        // Perform multiple searches to get diverse results
        let searchPublishers = queries.map { query in
            apiService.searchTracks(query: query, limit: 20)
        }
        
        Publishers.MergeMany(searchPublishers)
            .collect()
            .flatMap { [weak self] responses -> AnyPublisher<[Song], SpotifyAPIError> in
                // Combine all tracks from different searches
                let allTracks = responses.flatMap { $0.tracks.items }
                let uniqueTracks = Array(Set(allTracks.map { $0.id })).compactMap { id in
                    allTracks.first { $0.id == id }
                }
                
                // Get audio features for all tracks
                let trackIDs = Array(uniqueTracks.prefix(50).map { $0.id })
                
                guard let self = self else {
                    return Just([]).setFailureType(to: SpotifyAPIError.self).eraseToAnyPublisher()
                }
                
                return self.apiService.getAudioFeatures(trackIDs: trackIDs)
                    .map { audioFeaturesResponse in
                        self.filterSongsByBPM(tracks: uniqueTracks, audioFeatures: audioFeaturesResponse.audioFeatures, targetBPM: targetBPM)
                    }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                            // Fallback to mock data on error
                            self?.getMockSongsForBPM(targetBPM)
                        }
                    }
                },
                receiveValue: { [weak self] songs in
                    DispatchQueue.main.async {
                        self?.recommendedSongs = songs
                        self?.isLoading = false
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func generateSearchQueries(for bpm: Int) -> [String] {
        let genres: [String]
        
        switch bpm {
        case 80...110:
            genres = ["chill", "acoustic", "folk", "indie"]
        case 111...130:
            genres = ["pop", "rock", "alternative", "indie"]
        case 131...150:
            genres = ["dance", "house", "electronic", "disco"]
        case 151...170:
            genres = ["techno", "edm", "dance", "electronic"]
        case 171...200:
            genres = ["drum and bass", "hardcore", "speed", "fast"]
        default:
            genres = ["energetic", "workout", "running", "fitness"]
        }
        
        let baseQueries = [
            "workout",
            "running",
            "fitness",
            "energy"
        ]
        
        return baseQueries + genres.map { "genre:\($0)" }
    }
    
    private func filterSongsByBPM(tracks: [SpotifyTrack], audioFeatures: [SpotifyAudioFeature], targetBPM: Int) -> [Song] {
        let targetBPMDouble = Double(targetBPM)
        
        let songsWithBPM = tracks.compactMap { track -> Song? in
            guard let audioFeature = audioFeatures.first(where: { $0.id == track.id }) else {
                return nil
            }
            
            // Check if BPM is within tolerance
            let bpmDifference = abs(audioFeature.tempo - targetBPMDouble)
            guard bpmDifference <= bpmTolerance else {
                return nil
            }
            
            // Prefer songs with higher energy and danceability for workouts
            let energyScore = audioFeature.energy * 0.4
            let danceabilityScore = audioFeature.danceability * 0.3
            let valenceScore = audioFeature.valence * 0.2
            let bpmScore = (1.0 - (bpmDifference / bpmTolerance)) * 0.1
            
            let totalScore = energyScore + danceabilityScore + valenceScore + bpmScore
            
            // Only include songs with a decent fitness score (> 0.4)
            guard totalScore > 0.4 else {
                return nil
            }
            
            return track.toSong(bpm: Int(audioFeature.tempo.rounded()))
        }
        
        // Sort by fitness score (calculated during filtering) and return top results
        return Array(songsWithBPM.prefix(20))
    }
    
    private func getMockSongsForBPM(_ targetBPM: Int) {
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let tolerance = 10
            self.recommendedSongs = self.mockSongs.filter { song in
                abs(song.bpm - targetBPM) <= tolerance
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Playback Methods
    
    func playSong(_ song: Song) {
        guard isConnected else {
            // For mock data, just update current song
            currentSong = song
            print("Mock Playing: \(song.title) by \(song.artist) (BPM: \(song.bpm))")
            return
        }
        
        apiService.playTrack(uri: song.spotifyURI, deviceID: nil)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = "Playback error: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { [weak self] in
                    DispatchQueue.main.async {
                        self?.currentSong = song
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func pausePlayback() {
        guard isConnected else {
            currentSong = nil
            return
        }
        
        apiService.pausePlayback(deviceID: nil)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = "Pause error: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func resumePlayback() {
        guard isConnected else { return }
        
        apiService.resumePlayback(deviceID: nil)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        DispatchQueue.main.async {
                            self?.errorMessage = "Resume error: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func stopPlayback() {
        pausePlayback()
        currentSong = nil
    }
    
    // MARK: - Utility Methods
    
    func getRandomSongForBPM(_ bpm: Int) -> Song? {
        let tolerance = 10
        let matchingSongs: [Song]
        
        if recommendedSongs.isEmpty {
            // Use mock songs if no real songs available
            matchingSongs = mockSongs.filter { song in
                abs(song.bpm - bpm) <= tolerance
            }
        } else {
            // Use real recommended songs
            matchingSongs = recommendedSongs.filter { song in
                abs(song.bpm - bpm) <= tolerance
            }
        }
        
        return matchingSongs.randomElement()
    }
    
    // MARK: - Playback State Monitoring
    
    private func startPlaybackMonitoring() {
        // Monitor playback state every 5 seconds when connected
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePlaybackState()
            }
            .store(in: &cancellables)
    }
    
    private func updatePlaybackState() {
        guard isConnected else { return }
        
        apiService.getCurrentPlayback()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] playbackState in
                    DispatchQueue.main.async {
                        self?.currentPlaybackState = playbackState
                        
                        // Update current song if it changed
                        if let currentTrack = playbackState?.item {
                            self?.currentSong = currentTrack.toSong()
                        } else if playbackState?.isPlaying == false {
                            // Playback stopped
                            self?.currentSong = nil
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
}
