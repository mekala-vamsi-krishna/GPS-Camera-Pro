//
//  HomeView.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var  homeRouter:HomeRouterFlow = HomeRouterFlow()
    
    
    var body: some View {
        NavigationStack(path: $homeRouter.navPaths) {
            mainContent
                .navigationDestination(for: HomeFlow.self) { destination in
                    destination.destinationView
                }
                .navigationTitle(Utils.shared.APP_NAME)
                .navigationBarTitleDisplayMode(.large)
        }
    }
}
// MARK: SubViews
extension HomeView {
    private var mainContent: some View {
        VStack {
         Text("Hello world")
        }
    }
}

#Preview {
    HomeView()
}
