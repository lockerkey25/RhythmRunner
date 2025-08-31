//
//  SpotifyAPIService.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Combine

// MARK: - API Service Errors
enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case authenticationRequired
    case spotifyError(SpotifyErrorDetail)
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationRequired:
            return "Authentication required"
        case .spotifyError(let error):
            return "Spotify error: \(error.message)"
        case .tokenExpired:
            return "Access token expired"
        }
    }
}

// MARK: - API Service Protocol
protocol SpotifyAPIServiceProtocol {
    func searchTracks(query: String, limit: Int) -> AnyPublisher<SpotifySearchResponse, SpotifyAPIError>
    func getAudioFeatures(trackIDs: [String]) -> AnyPublisher<SpotifyAudioFeaturesResponse, SpotifyAPIError>
    func getCurrentPlayback() -> AnyPublisher<SpotifyPlaybackState?, SpotifyAPIError>
    func playTrack(uri: String, deviceID: String?) -> AnyPublisher<Void, SpotifyAPIError>
    func pausePlayback(deviceID: String?) -> AnyPublisher<Void, SpotifyAPIError>
    func resumePlayback(deviceID: String?) -> AnyPublisher<Void, SpotifyAPIError>
    func setAccessToken(_ token: String, expiresIn: Int)
    func getCurrentUserProfile() -> AnyPublisher<SpotifyUserProfile, SpotifyAPIError>
}

// MARK: - Spotify API Service Implementation
class SpotifyAPIService: SpotifyAPIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private var accessToken: String?
    private var tokenExpirationDate: Date?
    
    // Network retry configuration
    private let maxRetries = 3
    private let baseRetryDelay: TimeInterval = 1.0
    
    init() {
        // Configure URLSession with network-friendly settings
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Authentication
    func setAccessToken(_ token: String, expiresIn: Int) {
        self.accessToken = token
        self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
    }
    
    private var isTokenValid: Bool {
        guard let token = accessToken,
              let expiration = tokenExpirationDate else {
            return false
        }
        return !token.isEmpty && Date() < expiration
    }
    
    private func createRequest(url: URL, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard isTokenValid, let token = accessToken else {
            throw SpotifyAPIError.authenticationRequired
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Network Retry Logic
    private func performRequestWithRetry<T: Codable>(
        _ request: URLRequest,
        responseType: T.Type,
        retryCount: Int = 0
    ) -> AnyPublisher<T, SpotifyAPIError> {
        return session.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                // Check HTTP status codes
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        return data
                    case 401:
                        throw SpotifyAPIError.authenticationRequired
                    case 429: // Rate limited
                        throw SpotifyAPIError.networkError(URLError(.cannotLoadFromNetwork))
                    case 500...599: // Server errors - retry these
                        throw SpotifyAPIError.networkError(URLError(.badServerResponse))
                    default:
                        throw SpotifyAPIError.networkError(URLError(.badServerResponse))
                    }
                }
                return data
            }
            .decode(type: responseType, decoder: decoder)
            .mapError { error -> SpotifyAPIError in
                if let spotifyError = error as? SpotifyAPIError {
                    return spotifyError
                } else if error is DecodingError {
                    return SpotifyAPIError.decodingError(error)
                } else {
                    return SpotifyAPIError.networkError(error)
                }
            }
            .catch { [weak self] error -> AnyPublisher<T, SpotifyAPIError> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                // Check if we should retry
                if self.shouldRetry(error: error, retryCount: retryCount) {
                    let delay = self.calculateRetryDelay(retryCount: retryCount)
                    print("[SpotifyAPI] Retrying request in \(delay)s (attempt \(retryCount + 1)/\(self.maxRetries))")
                    
                    return Just(())
                        .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                        .flatMap { _ in
                            self.performRequestWithRetry(request, responseType: responseType, retryCount: retryCount + 1)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func shouldRetry(error: SpotifyAPIError, retryCount: Int) -> Bool {
        guard retryCount < maxRetries else { return false }
        
        switch error {
        case .networkError(let underlyingError):
            // Retry network errors (timeouts, connection issues, server errors)
            if let urlError = underlyingError as? URLError {
                switch urlError.code {
                case .timedOut, .cannotConnectToHost, .networkConnectionLost, 
                     .notConnectedToInternet, .cannotLoadFromNetwork, .badServerResponse:
                    return true
                default:
                    return false
                }
            }
            return true
        case .authenticationRequired, .decodingError, .invalidURL, .noData, .spotifyError, .tokenExpired:
            return false
        }
    }
    
    private func calculateRetryDelay(retryCount: Int) -> TimeInterval {
        // Exponential backoff with jitter
        let exponentialDelay = baseRetryDelay * pow(2.0, Double(retryCount))
        let jitter = Double.random(in: 0.0...0.1) * exponentialDelay
        return min(exponentialDelay + jitter, 30.0) // Cap at 30 seconds
    }
    
    // MARK: - Generic Request Method
    private func performRequest<T: Codable>(
        _ request: URLRequest,
        responseType: T.Type
    ) -> AnyPublisher<T, SpotifyAPIError> {
        return performRequestWithRetry(request, responseType: responseType)
    }
    
    // MARK: - API Methods
    
    func searchTracks(query: String, limit: Int = 50) -> AnyPublisher<SpotifySearchResponse, SpotifyAPIError> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.searchEndpoint)?q=\(encodedQuery)&type=track&limit=\(limit)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try createRequest(url: url)
            return performRequest(request, responseType: SpotifySearchResponse.self)
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func getAudioFeatures(trackIDs: [String]) -> AnyPublisher<SpotifyAudioFeaturesResponse, SpotifyAPIError> {
        let idsString = trackIDs.joined(separator: ",")
        let urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.audioFeaturesEndpoint)?ids=\(idsString)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try createRequest(url: url)
            return performRequest(request, responseType: SpotifyAudioFeaturesResponse.self)
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func getCurrentPlayback() -> AnyPublisher<SpotifyPlaybackState?, SpotifyAPIError> {
        let urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.mePlayerEndpoint)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try createRequest(url: url)
            return session.dataTaskPublisher(for: request)
                .map { (data: Data, response: URLResponse) -> Data? in
                    // Handle 204 No Content (no active playback)
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 {
                        return nil
                    }
                    return data
                }
                .tryMap { [weak self] (data: Data?) -> SpotifyPlaybackState? in
                    guard let data = data, let self = self else { return nil }
                    return try self.decoder.decode(SpotifyPlaybackState.self, from: data)
                }
                .mapError { error in
                    SpotifyAPIError.networkError(error)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func playTrack(uri: String, deviceID: String? = nil) -> AnyPublisher<Void, SpotifyAPIError> {
        var urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.mePlayerPlayEndpoint)"
        if let deviceID = deviceID {
            urlString += "?device_id=\(deviceID)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let body = ["uris": [uri]]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            let request = try createRequest(url: url, method: "PUT", body: bodyData)
            
            return session.dataTaskPublisher(for: request)
                .map { _ in () }
                .mapError { SpotifyAPIError.networkError($0) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func pausePlayback(deviceID: String? = nil) -> AnyPublisher<Void, SpotifyAPIError> {
        var urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.mePlayerPauseEndpoint)"
        if let deviceID = deviceID {
            urlString += "?device_id=\(deviceID)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try createRequest(url: url, method: "PUT")
            
            return session.dataTaskPublisher(for: request)
                .map { _ in () }
                .mapError { SpotifyAPIError.networkError($0) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func resumePlayback(deviceID: String? = nil) -> AnyPublisher<Void, SpotifyAPIError> {
        var urlString = "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.mePlayerPlayEndpoint)"
        if let deviceID = deviceID {
            urlString += "?device_id=\(deviceID)"
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: SpotifyAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        do {
            let request = try createRequest(url: url, method: "PUT")
            
            return session.dataTaskPublisher(for: request)
                .map { _ in () }
                .mapError { SpotifyAPIError.networkError($0) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error as? SpotifyAPIError ?? SpotifyAPIError.networkError(error))
                .eraseToAnyPublisher()
        }
    }
    
    func getCurrentUserProfile() -> AnyPublisher<SpotifyUserProfile, SpotifyAPIError> {
        let url = URL(string: "\(SpotifyConfig.spotifyAPIBaseURL)\(SpotifyConfig.meEndpoint)")!
        let request = try! createRequest(url: url)
        
        return performRequestWithRetry(request, responseType: SpotifyUserProfile.self)
    }
}
