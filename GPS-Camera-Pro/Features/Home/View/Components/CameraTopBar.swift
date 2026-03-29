//
//  CameraTopBar.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

/// Top toolbar with camera control icons matching the reference design
struct CameraTopBar: View {
    var onMenuTap: () -> Void
    var onFilterTap: () -> Void
    var onFlashTap: () -> Void
    var onTimerTap: () -> Void
    var onAspectRatioTap: () -> Void
    var onSettingsTap: () -> Void
    var onToggleCameraTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side icons
            HStack(spacing: 16) {
                topBarButton(icon: "line.3.horizontal", action: onMenuTap)
                topBarButton(icon: "photo.artframe", action: onFilterTap)
                topBarButton(icon: "bolt.slash.fill", action: onFlashTap)
                topBarButton(icon: "timer", action: onTimerTap)
                topBarButton(icon: "aspectratio", action: onAspectRatioTap)
                topBarButton(icon: "slider.horizontal.3", action: onSettingsTap)
            }
            
            Spacer()
            
            // Camera toggle
            Button(action: onToggleCameraTap) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("1")
                        .font(.customFont(.bold, size: 14))
                        .foregroundColor(.white)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func topBarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
