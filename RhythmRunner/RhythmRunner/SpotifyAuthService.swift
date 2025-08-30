//
//  SpotifyAuthService.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Combine
import AuthenticationServices
import CryptoKit

// MARK: - Authentication Service Protocol
protocol SpotifyAuthServiceProtocol {
    func authenticate() -> AnyPublisher<SpotifyTokenResponse, SpotifyAPIError>
    func refreshToken(_ refreshToken: String) -> AnyPublisher<SpotifyTokenResponse, SpotifyAPIError>
    func logout()
}

// MARK: - Spotify Authentication Service
class SpotifyAuthService: NSObject, SpotifyAuthServiceProtocol, ASWebAuthenticationPresentationContextProviding {
    
    private let session = URLSession.shared
    private var webAuthSession: ASWebAuthenticationSession?
    private var authPublisher: PassthroughSubject<SpotifyTokenResponse, SpotifyAPIError>?
    
    // MARK: - Public Methods
    
    func authenticate() -> AnyPublisher<SpotifyTokenResponse, SpotifyAPIError> {
        let publisher = PassthroughSubject<SpotifyTokenResponse, SpotifyAPIError>()
        self.authPublisher = publisher
        
        guard !SpotifyConfig.clientID.isEmpty && SpotifyConfig.clientID != "YOUR_SPOTIFY_CLIENT_ID" else {
            publisher.send(completion: .failure(.authenticationRequired))
            return publisher.eraseToAnyPublisher()
        }
        
        let authURL = buildAuthURL()
        
        guard let url = URL(string: authURL) else {
            publisher.send(completion: .failure(.invalidURL))
            return publisher.eraseToAnyPublisher()
        }
        
        webAuthSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "rhythmrunner"
        ) { [weak self] callbackURL, error in
            if let error = error {
                if case ASWebAuthenticationSessionError.canceledLogin = error {
                    // User cancelled the login
                    publisher.send(completion: .finished)
                } else {
                    publisher.send(completion: .failure(.networkError(error)))
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                publisher.send(completion: .failure(.authenticationRequired))
                return
            }
            
            self?.handleAuthCallback(callbackURL, publisher: publisher)
        }
        
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.prefersEphemeralWebBrowserSession = false
        webAuthSession?.start()
        
        return publisher.eraseToAnyPublisher()
    }
    
    func refreshToken(_ refreshToken: String) -> AnyPublisher<SpotifyTokenResponse, SpotifyAPIError> {
        let url = URL(string: "\(SpotifyConfig.spotifyAccountsBaseURL)/api/token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create authorization header
        let credentials = "\(SpotifyConfig.clientID):"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Create body
        let bodyString = "grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = bodyString.data(using: .utf8)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SpotifyTokenResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return SpotifyAPIError.decodingError(error)
                } else {
                    return SpotifyAPIError.networkError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func logout() {
        // Clear any stored tokens
        UserDefaults.standard.removeObject(forKey: "SpotifyAccessToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyRefreshToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyTokenExpiration")
    }
    
    // MARK: - Private Methods
    
    private func buildAuthURL() -> String {
        let scopes = SpotifyConfig.scopes.joined(separator: " ")
        let state = generateRandomString(length: 16)
        let codeChallenge = generateCodeChallenge()
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: SpotifyConfig.clientID),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "redirect_uri", value: SpotifyConfig.redirectURI),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge)
        ]
        
        let baseURL = "\(SpotifyConfig.spotifyAccountsBaseURL)/authorize"
        return baseURL + "?" + (components.query ?? "")
    }
    
    private func handleAuthCallback(_ url: URL, publisher: PassthroughSubject<SpotifyTokenResponse, SpotifyAPIError>) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let error = components?.queryItems?.first(where: { $0.name == "error" })?.value {
            let errorDescription = components?.queryItems?.first(where: { $0.name == "error_description" })?.value ?? error
            publisher.send(completion: .failure(.networkError(NSError(domain: "SpotifyAuth", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDescription]))))
            return
        }
        
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
            publisher.send(completion: .failure(.authenticationRequired))
            return
        }
        
        exchangeCodeForTokens(code: code, publisher: publisher)
    }
    
    private func exchangeCodeForTokens(code: String, publisher: PassthroughSubject<SpotifyTokenResponse, SpotifyAPIError>) {
        let url = URL(string: "\(SpotifyConfig.spotifyAccountsBaseURL)/api/token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // For PKCE flow, we don't use Basic auth, instead we send client_id in the body
        // Remove the authorization header for PKCE
        // request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Create body - for PKCE flow, include client_id in the body
        let codeVerifier = getStoredCodeVerifier() ?? ""
        let bodyString = "grant_type=authorization_code&client_id=\(SpotifyConfig.clientID)&code=\(code)&redirect_uri=\(SpotifyConfig.redirectURI)&code_verifier=\(codeVerifier)"
        request.httpBody = bodyString.data(using: .utf8)
        
        print("🔑 Exchanging code for tokens...")
        print("📝 Request URL: \(url.absoluteString)")
        print("📝 Request body: \(bodyString)")
        print("📝 Client ID: \(SpotifyConfig.clientID)")
        print("📝 Redirect URI: \(SpotifyConfig.redirectURI)")
        print("📝 Code verifier length: \(codeVerifier.count)")
        
        session.dataTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) -> Data in
                print("📡 Received response from Spotify")
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📡 Response headers: \(httpResponse.allHeaderFields)")
                }
                
                print("📡 Response data length: \(data.count) bytes")
                
                if data.isEmpty {
                    print("❌ Empty response data received")
                    throw SpotifyAPIError.noData
                }
                
                // Try to parse as string for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📡 Response body: \(responseString)")
                } else {
                    print("❌ Could not convert response to string")
                }
                
                // Check for HTTP error status codes
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        // Try to decode as Spotify error
                        if let errorData = try? JSONDecoder().decode(SpotifyError.self, from: data) {
                            throw SpotifyAPIError.spotifyError(errorData.error)
                        } else {
                            throw SpotifyAPIError.networkError(NSError(domain: "SpotifyAuth", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"]))
                        }
                    }
                }
                
                return data
            }
            .decode(type: SpotifyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("❌ Token exchange failed: \(error)")
                        if let decodingError = error as? DecodingError {
                            print("❌ Decoding error details: \(decodingError)")
                            publisher.send(completion: .failure(.decodingError(decodingError)))
                        } else if let spotifyError = error as? SpotifyAPIError {
                            publisher.send(completion: .failure(spotifyError))
                        } else {
                            publisher.send(completion: .failure(.networkError(error)))
                        }
                    case .finished:
                        print("✅ Token exchange completed successfully")
                        break
                    }
                },
                receiveValue: { tokenResponse in
                    print("✅ Successfully decoded token response")
                    print("🔑 Access token length: \(tokenResponse.accessToken.count)")
                    print("🔑 Token expires in: \(tokenResponse.expiresIn) seconds")
                    print("🔑 Refresh token available: \(tokenResponse.refreshToken != nil)")
                    
                    // Store tokens securely
                    self.storeTokens(tokenResponse)
                    publisher.send(tokenResponse)
                    publisher.send(completion: .finished)
                }
            )
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func storeTokens(_ tokenResponse: SpotifyTokenResponse) {
        UserDefaults.standard.set(tokenResponse.accessToken, forKey: "SpotifyAccessToken")
        if let refreshToken = tokenResponse.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "SpotifyRefreshToken")
        }
        let expirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        UserDefaults.standard.set(expirationDate, forKey: "SpotifyTokenExpiration")
    }
    
    // MARK: - PKCE Helper Methods
    
    private func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func generateCodeChallenge() -> String {
        let codeVerifier = generateRandomString(length: 128)
        UserDefaults.standard.set(codeVerifier, forKey: "SpotifyCodeVerifier")
        
        let challenge = codeVerifier.data(using: .utf8)!
            .sha256()
            .base64URLEncodedString()
        
        return challenge
    }
    
    private func getStoredCodeVerifier() -> String? {
        return UserDefaults.standard.string(forKey: "SpotifyCodeVerifier")
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

// MARK: - Data Extensions for PKCE
extension Data {
    func sha256() -> Data {
        return Data(SHA256.hash(data: self))
    }
    
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
