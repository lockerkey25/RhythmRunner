//
//  SpotifyModels.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation

// MARK: - Authentication Models
struct SpotifyTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

// MARK: - Search API Models
struct SpotifySearchResponse: Codable {
    let tracks: SpotifyTracksResponse
}

struct SpotifyTracksResponse: Codable {
    let href: String
    let items: [SpotifyTrack]
    let limit: Int
    let offset: Int
    let total: Int
}

struct SpotifyTrack: Codable, Identifiable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
    let durationMs: Int
    let explicit: Bool
    let externalUrls: SpotifyExternalUrls
    let href: String
    let popularity: Int
    let previewUrl: String?
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, album, explicit, href, popularity, uri
        case durationMs = "duration_ms"
        case externalUrls = "external_urls"
        case previewUrl = "preview_url"
    }
}

struct SpotifyArtist: Codable {
    let id: String
    let name: String
    let href: String
    let uri: String
    let externalUrls: SpotifyExternalUrls
    
    enum CodingKeys: String, CodingKey {
        case id, name, href, uri
        case externalUrls = "external_urls"
    }
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let releaseDate: String
    let totalTracks: Int
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, images, uri
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
    }
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyExternalUrls: Codable {
    let spotify: String
}

// MARK: - Audio Features Models
struct SpotifyAudioFeaturesResponse: Codable {
    let audioFeatures: [SpotifyAudioFeature]
    
    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }
}

struct SpotifyAudioFeature: Codable {
    let id: String
    let tempo: Double
    let energy: Double
    let danceability: Double
    let valence: Double
    let acousticness: Double
    let instrumentalness: Double
    let liveness: Double
    let speechiness: Double
    let loudness: Double
    let key: Int
    let mode: Int
    let timeSignature: Int
    let durationMs: Int
    
    enum CodingKeys: String, CodingKey {
        case id, tempo, energy, danceability, valence, acousticness, instrumentalness, liveness, speechiness, loudness, key, mode
        case timeSignature = "time_signature"
        case durationMs = "duration_ms"
    }
}

// MARK: - User Profile Models
struct SpotifyUserProfile: Codable {
    let id: String
    let displayName: String?
    let email: String?
    let country: String?
    let product: String? // "premium", "free", etc.
    let images: [SpotifyImage]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case email
        case country
        case product
        case images
    }
}


// MARK: - Playback Models
struct SpotifyPlaybackState: Codable {
    let device: SpotifyDevice?
    let repeatState: String
    let shuffleState: Bool
    let context: SpotifyContext?
    let timestamp: Int64
    let progressMs: Int?
    let isPlaying: Bool
    let item: SpotifyTrack?
    
    enum CodingKeys: String, CodingKey {
        case device, context, timestamp, item
        case repeatState = "repeat_state"
        case shuffleState = "shuffle_state"
        case progressMs = "progress_ms"
        case isPlaying = "is_playing"
    }
}

struct SpotifyDevice: Codable {
    let id: String?
    let isActive: Bool
    let isPrivateSession: Bool
    let isRestricted: Bool
    let name: String
    let type: String
    let volumePercent: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case volumePercent = "volume_percent"
    }
}

struct SpotifyContext: Codable {
    let type: String
    let href: String?
    let externalUrls: SpotifyExternalUrls?
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case type, href, uri
        case externalUrls = "external_urls"
    }
}

// MARK: - Error Models
struct SpotifyError: Codable, Error {
    let error: SpotifyErrorDetail
}

struct SpotifyErrorDetail: Codable {
    let status: Int
    let message: String
}

// MARK: - Helper Extensions
extension SpotifyTrack {
    func toSong(bpm: Int = 0) -> Song {
        Song(
            id: self.id,
            title: self.name,
            artist: self.artists.first?.name ?? "Unknown Artist",
            album: self.album.name,
            bpm: bpm,
            spotifyURI: self.uri,
            albumArtURL: self.album.images.first?.url
        )
    }
}
