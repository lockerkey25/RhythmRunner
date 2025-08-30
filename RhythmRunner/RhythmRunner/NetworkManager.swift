//
//  NetworkManager.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Network
import Combine

// MARK: - Network Status
enum NetworkStatus {
    case connected
    case disconnected
    case unknown
    
    var isConnected: Bool {
        return self == .connected
    }
}

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    @Published var networkStatus: NetworkStatus = .unknown
    @Published var isConnected: Bool = false
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        startNetworkMonitoring()
    }
    
    deinit {
        stopNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newStatus: NetworkStatus = path.status == .satisfied ? .connected : .disconnected
                
                if self?.networkStatus != newStatus {
                    self?.networkStatus = newStatus
                    self?.isConnected = newStatus.isConnected
                }
            }
        }
        
        networkMonitor.start(queue: workerQueue)
    }
    
    private func stopNetworkMonitoring() {
        networkMonitor.cancel()
    }
    
    // MARK: - Network Quality Check
    
    func checkNetworkQuality() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            // Simple network quality check by attempting to reach Spotify API
            guard let url = URL(string: "https://api.spotify.com") else {
                promise(.success(false))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 5.0
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode == 200 || httpResponse.statusCode == 401 { // 401 is expected without auth
                        promise(.success(true))
                    } else {
                        promise(.success(false))
                    }
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
}
