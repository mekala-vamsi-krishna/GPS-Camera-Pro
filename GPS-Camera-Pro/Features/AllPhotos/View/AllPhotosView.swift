//
//  AllPhotosView.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

struct AllPhotosView: View {
    @StateObject private var router = AllPhotosRouterFlow()
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                FeatureNavBar(title: "All Photos") {
                    presentSideMenu = true
                }
                
                // MARK: - Content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("All Photos")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 40)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .background(featureBackground)
            .navigationBarHidden(true)
            .navigationDestination(for: AllPhotosFlow.self) { destination in
                destination.destinationView
            }
        }
    }
}

#Preview {
    AllPhotosView(presentSideMenu: .constant(false))
}
