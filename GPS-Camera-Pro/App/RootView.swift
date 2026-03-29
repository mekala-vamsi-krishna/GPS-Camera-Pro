//
//  ContentView.swift
//  GPS-Camera-Pro
//
//  Created by User on 25/03/26.
//

import SwiftUI
import Combine

class AppState : ObservableObject {
    @Published var  appState: AppStates = .home
    
    init(){
        print("App State Init")
    }
    
    deinit {
        print("App State Deinit")
    }
}


struct RootView: View {
    @EnvironmentObject private var appState:AppState
    var body: some View {
        if appState.appState == .home {
            HomeView()
        } else{
            LoginView()
        }
    }
}

#Preview {
    RootView()
}
