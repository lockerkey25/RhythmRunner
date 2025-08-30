//
//  NetworkMonitor.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    @Published var connectionType: ConnectionType = .unknown
    @Published var isExpensive = false
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
        
        var description: String {
            switch self {
            case .wifi:
                return "Wi-Fi"
            case .cellular:
                return "Cellular"
            case .ethernet:
                return "Ethernet"
            case .unknown:
                return "Unknown"
            }
        }
        
        var icon: String {
            switch self {
            case .wifi:
                return "wifi"
            case .cellular:
                return "antenna.radiowaves.left.and.right"
            case .ethernet:
                return "cable.connector"
            case .unknown:
                return "questionmark.circle"
            }
        }
    }
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    // MARK: - Public Methods
    
    func checkConnectivity() -> Bool {
        return isConnected
    }
    
    func isOptimalForStreaming() -> Bool {
        return isConnected && !isExpensive && connectionType != .cellular
    }
    
    func getNetworkStatus() -> String {
        if !isConnected {
            return "No internet connection"
        }
        
        var status = "Connected via \(connectionType.description)"
        if isExpensive {
            status += " (Limited data)"
        }
        return status
    }
    
    func shouldShowDataWarning() -> Bool {
        return isConnected && isExpensive && connectionType == .cellular
    }
}
