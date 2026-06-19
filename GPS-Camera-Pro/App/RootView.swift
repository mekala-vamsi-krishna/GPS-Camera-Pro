//
//  RootView.swift
//  GPS-Camera-Pro
//
//  Created by User on 25/03/26.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var appState: AppStates = .home
    @Published var selectedTab: SideMenuRowType = .home
    
    init() {
        print("AppState Init")
    }
    
    deinit {
        print("AppState Deinit")
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        if appState.appState == .home {
            MainContainerView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
