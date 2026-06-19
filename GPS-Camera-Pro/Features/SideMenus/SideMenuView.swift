//
//  SideMenuView.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

// MARK: - Menu Item Definition
enum SideMenuRowType: Int, CaseIterable {
    case home = 0
    case favorite
    case allPhotos
    case profile
    
    var title: String {
        switch self {
        case .home:      return "Home"
        case .favorite:  return "Favorites"
        case .allPhotos: return "All Photos"
        case .profile:   return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:      return "house.fill"
        case .favorite:  return "heart.fill"
        case .allPhotos: return "photo.on.rectangle.angled"
        case .profile:   return "person.fill"
        }
    }
}

// MARK: - Side Menu View
struct SideMenuView: View {
    @Binding var selectedTab: Int
    var onItemSelected: (SideMenuRowType) -> Void
    
    // MARK: - App Version Info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile header
            profileHeader
                .padding(.top, 64)
                .padding(.bottom, 36)
            
            // Divider line
            Rectangle()
                .fill(Color.purple.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            // Menu items
            ForEach(SideMenuRowType.allCases, id: \.self) { row in
                menuRow(row)
            }
            
            Spacer()
            
            // Version and Build label
            VStack(spacing: 4) {
                Text("Version \(appVersion) (Build \(buildNumber))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
        }
        .frame(width: 280)
        .background(
            ZStack {
                // Rich dark slate base
                Color(red: 0.05, green: 0.04, blue: 0.08)
                
                // ambient purple glow from top-left
                LinearGradient(
                    colors: [Color.purple.opacity(0.18), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .ignoresSafeArea(.all, edges: .vertical)
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 76, height: 76)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .purple.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 76, height: 76)
                
                Image(systemName: "camera.shutter.button.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: .purple.opacity(0.25), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 4) {
                Text("GPS Camera Pro")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Vibrant Location Tags")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.purple.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Menu Row
    private func menuRow(_ row: SideMenuRowType) -> some View {
        let isSelected = selectedTab == row.rawValue
        
        return Button {
            selectedTab = row.rawValue
            onItemSelected(row)
        } label: {
            HStack(spacing: 16) {
                // Selection indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? Color.purple : Color.clear)
                    .frame(width: 4, height: 24)
                
                Image(systemName: row.iconName)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                    .frame(width: 28)
                
                Text(row.title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                
                Spacer()
            }
        }
        .frame(height: 52)
        .background(
            isSelected
                ? LinearGradient(
                    colors: [Color.purple.opacity(0.22), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                : LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
        )
    }
}
