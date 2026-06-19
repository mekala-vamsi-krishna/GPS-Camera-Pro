//
//  FeatureNavBar.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

// MARK: - Shared Feature Navigation Bar
/// Reusable dark-purple navigation bar with hamburger menu button.
/// Used by all non-camera feature screens (Favourites, AllPhotos, Profile)
/// for a consistent look across the app.
struct FeatureNavBar: View {
    let title: String
    let onMenuTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    onMenuTap()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.purple)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Color(red: 0.05, green: 0.04, blue: 0.08)
                LinearGradient(
                    colors: [Color.purple.opacity(0.12), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .shadow(color: .purple.opacity(0.15), radius: 5, y: 3)
    }
}

// MARK: - Shared Feature Background
/// Consistent dark-purple background for feature screens.
extension View {
    var featureBackground: some View {
        ZStack {
            Color(red: 0.05, green: 0.04, blue: 0.08)
            LinearGradient(
                colors: [Color.purple.opacity(0.08), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
