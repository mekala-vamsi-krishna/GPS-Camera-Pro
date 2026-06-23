//
//  HelpGuideSheet.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

struct HelpGuideSheet: View {
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GPS Camera Pro")
                        .font(.customFont(.bold, size: 24))
                        .foregroundColor(.white)
                    Text("How to use the application")
                        .font(.customFont(.medium, size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Tip 1
                    helpRow(
                        icon: "camera.fill",
                        iconColor: .blue,
                        title: "Real-Time Geotagging",
                        description: "Every photo you take instantly captures precise coordinates, sub-addresses, timestamps, and a satellite mini map."
                    )
                    
                    // Tip 2
                    helpRow(
                        icon: "hand.tap.fill",
                        iconColor: .purple,
                        title: "Draggable Overlay",
                        description: "Tap and drag the Geotag Stamp anywhere on the camera preview screen to custom position your watermark before capturing."
                    )
                    
                    // Tip 3
                    helpRow(
                        icon: "seal.fill",
                        iconColor: .orange,
                        title: "Customizable Stamps",
                        description: "Tap the Stamp button in the bottom bar to toggle stamp details (map, address, coordinates, datetime) and choose a premium background tint."
                    )
                    
                    // Tip 4
                    helpRow(
                        icon: "square.grid.2x2.fill",
                        iconColor: .green,
                        title: "Pinterest Staggered Gallery",
                        description: "Access your captured photos from the side menu or by tapping 'My Photos' in the bottom bar, shown in a clean staggered layout."
                    )
                    
                    // Tip 5
                    helpRow(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: "Favorites System",
                        description: "Tap the heart on any photo to favorite it. Filter your favorites tab to quickly browse through your best memories."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 32)
            }
        }
        .background(
            Color(red: 0.08, green: 0.07, blue: 0.12)
                .ignoresSafeArea()
        )
    }
    
    private func helpRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.customFont(.semibold, size: 16))
                    .foregroundColor(.white)
                Text(description)
                    .font(.customFont(.regular, size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(3)
            }
        }
    }
}
