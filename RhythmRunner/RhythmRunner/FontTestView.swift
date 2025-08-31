//
//  FontTestView.swift
//  RhythmRunner
//
//  Created by yyz on 2025-08-30.
//

import SwiftUI

struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Font Test - SF Pro Display")
                    .font(FontConfig.displayLarge)
                    .foregroundColor(.primary)
                
                Text("Display Title")
                    .font(FontConfig.displayTitle)
                    .foregroundColor(.primary)
                
                Text("Display Title 2")
                    .font(FontConfig.displayTitle2)
                    .foregroundColor(.primary)
                
                Text("Display Title 3")
                    .font(FontConfig.displayTitle3)
                    .foregroundColor(.primary)
                
                Text("Display Headline")
                    .font(FontConfig.displayHeadline)
                    .foregroundColor(.primary)
                
                Text("Display Body")
                    .font(FontConfig.displayBody)
                    .foregroundColor(.primary)
                
                Text("Display Caption")
                    .font(FontConfig.displayCaption)
                    .foregroundColor(.primary)
                
                Divider()
                
                Text("Font Test - SF Pro Text")
                    .font(FontConfig.textLarge)
                    .foregroundColor(.primary)
                
                Text("Text Title")
                    .font(FontConfig.textTitle)
                    .foregroundColor(.primary)
                
                Text("Text Headline")
                    .font(FontConfig.textHeadline)
                    .foregroundColor(.primary)
                
                Text("Text Body")
                    .font(FontConfig.textBody)
                    .foregroundColor(.primary)
                
                Text("Text Subheadline")
                    .font(FontConfig.textSubheadline)
                    .foregroundColor(.primary)
                
                Text("Text Caption")
                    .font(FontConfig.textCaption)
                    .foregroundColor(.primary)
                
                Text("Text Caption 2")
                    .font(FontConfig.textCaption2)
                    .foregroundColor(.primary)
                
                Divider()
                
                Text("Font Test - SF Mono")
                    .font(FontConfig.monoLarge)
                    .foregroundColor(.primary)
                
                Text("Mono Medium")
                    .font(FontConfig.monoMedium)
                    .foregroundColor(.primary)
                
                Text("Mono Small")
                    .font(FontConfig.monoSmall)
                    .foregroundColor(.primary)
            }
            .padding()
        }
        .navigationTitle("Font Test")
    }
}

#Preview {
    FontTestView()
}
