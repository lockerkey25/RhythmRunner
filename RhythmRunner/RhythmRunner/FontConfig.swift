//
//  FontConfig.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct FontConfig {
    // MARK: - Display Fonts (SF Pro Display)
    static let displayLarge = Font.custom("SF Pro Display", size: 60, relativeTo: .largeTitle)
    static let displayTitle = Font.custom("SF Pro Display", size: 32, relativeTo: .title)
    static let displayTitle2 = Font.custom("SF Pro Display", size: 28, relativeTo: .title2)
    static let displayTitle3 = Font.custom("SF Pro Display", size: 20, relativeTo: .title3)
    static let displayHeadline = Font.custom("SF Pro Display", size: 18, relativeTo: .headline)
    static let displayBody = Font.custom("SF Pro Display", size: 16, relativeTo: .body)
    static let displayCaption = Font.custom("SF Pro Display", size: 12, relativeTo: .caption)
    
    // MARK: - Text Fonts (SF Pro Text)
    static let textLarge = Font.custom("SF Pro Text", size: 24, relativeTo: .largeTitle)
    static let textTitle = Font.custom("SF Pro Text", size: 20, relativeTo: .title3)
    static let textHeadline = Font.custom("SF Pro Text", size: 18, relativeTo: .headline)
    static let textBody = Font.custom("SF Pro Text", size: 16, relativeTo: .body)
    static let textSubheadline = Font.custom("SF Pro Text", size: 16, relativeTo: .subheadline)
    static let textCaption = Font.custom("SF Pro Text", size: 12, relativeTo: .caption)
    static let textCaption2 = Font.custom("SF Pro Text", size: 10, relativeTo: .caption2)
    
    // MARK: - Monospaced Fonts
    static let monoLarge = Font.custom("SF Mono", size: 58, relativeTo: .largeTitle)
    static let monoMedium = Font.custom("SF Mono", size: 48, relativeTo: .title)
    static let monoSmall = Font.custom("SF Mono", size: 20, relativeTo: .title3)
}
