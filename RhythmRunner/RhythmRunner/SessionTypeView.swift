//
//  SessionTypeView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct SessionTypeView: View {
    @Binding var selectedSessionType: SessionType
    @Binding var selectedDuration: RunningDuration?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Choose Session Type")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            // Session Type Selection
            VStack(spacing: 15) {
                // Timed Session Option
                Button(action: {
                    selectedSessionType = .timed
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "timer")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("Timed Session")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                
                                Spacer()
                                
                                if selectedSessionType == .timed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                            
                            Text("Set a specific duration for your workout")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedSessionType == .timed ? 
                                  Color.blue.opacity(0.1) : 
                                  (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedSessionType == .timed ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Free Run Option
                Button(action: {
                    selectedSessionType = .freeRun
                    selectedDuration = nil
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "infinity")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                Text("Free Run")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                
                                Spacer()
                                
                                if selectedSessionType == .freeRun {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                            }
                            
                            Text("Run for as long as you want")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedSessionType == .freeRun ? 
                                  Color.green.opacity(0.1) : 
                                  (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedSessionType == .freeRun ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Duration Selection (only for timed sessions)
            if selectedSessionType == .timed {
                VStack(spacing: 15) {
                    Text("Select Duration")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(RunningDuration.allCases, id: \.self) { duration in
                            Button(action: {
                                selectedDuration = duration
                            }) {
                                VStack(spacing: 8) {
                                    Text(duration.displayText)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                    Text(duration.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedDuration == duration ? 
                                              Color.blue.opacity(0.2) : 
                                              (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedDuration == duration ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 1.5)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedSessionType)
    }
}

enum SessionType {
    case timed
    case freeRun
}

enum RunningDuration: CaseIterable {
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case twentyMinutes
    case thirtyMinutes
    case fortyFiveMinutes
    case sixtyMinutes
    
    var displayText: String {
        switch self {
        case .fiveMinutes: return "5 min"
        case .tenMinutes: return "10 min"
        case .fifteenMinutes: return "15 min"
        case .twentyMinutes: return "20 min"
        case .thirtyMinutes: return "30 min"
        case .fortyFiveMinutes: return "45 min"
        case .sixtyMinutes: return "60 min"
        }
    }
    
    var description: String {
        switch self {
        case .fiveMinutes: return "Quick warm-up"
        case .tenMinutes: return "Short run"
        case .fifteenMinutes: return "Light workout"
        case .twentyMinutes: return "Moderate run"
        case .thirtyMinutes: return "Standard run"
        case .fortyFiveMinutes: return "Long run"
        case .sixtyMinutes: return "Endurance"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .fiveMinutes: return 5 * 60
        case .tenMinutes: return 10 * 60
        case .fifteenMinutes: return 15 * 60
        case .twentyMinutes: return 20 * 60
        case .thirtyMinutes: return 30 * 60
        case .fortyFiveMinutes: return 45 * 60
        case .sixtyMinutes: return 60 * 60
        }
    }
}

#Preview {
    SessionTypeView(selectedSessionType: .constant(.timed), selectedDuration: .constant(.tenMinutes))
}
