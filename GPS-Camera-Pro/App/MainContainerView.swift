//
//  MainContainerView.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

/// Root shell container that manages:
/// 1. Switching between feature tabs (each feature owns its own NavigationStack)
/// 2. Shared Side Menu overlay across all tabs
struct MainContainerView: View {
    @EnvironmentObject private var appState: AppState
    @State private var presentSideMenu: Bool = false
    
    var body: some View {
        ZStack {
            // All feature views remain alive — hidden via opacity.
            // This prevents @StateObject deallocation crashes when switching tabs.
            HomeView(presentSideMenu: $presentSideMenu)
                .opacity(appState.selectedTab == .home ? 1 : 0)
                .allowsHitTesting(appState.selectedTab == .home)
            
            Favourites(presentSideMenu: $presentSideMenu)
                .opacity(appState.selectedTab == .favorite ? 1 : 0)
                .allowsHitTesting(appState.selectedTab == .favorite)
            
            AllPhotosView(presentSideMenu: $presentSideMenu)
                .opacity(appState.selectedTab == .allPhotos ? 1 : 0)
                .allowsHitTesting(appState.selectedTab == .allPhotos)
            
            // MARK: - Side Menu Overlay (shared across all tabs)
            if presentSideMenu {
                // Dimming backdrop
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(10)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            presentSideMenu = false
                        }
                    }
                
                // Side menu panel — slides from leading edge
                HStack(spacing: 0) {
                    SideMenuView(
                        selectedTab: Binding(
                            get: { appState.selectedTab.rawValue },
                            set: { newValue in
                                if let tab = SideMenuRowType(rawValue: newValue) {
                                    appState.selectedTab = tab
                                }
                            }
                        )
                    ) { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            presentSideMenu = false
                        }
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                .transition(.move(edge: .leading))
                .zIndex(11)
            }
        }
    }
}
