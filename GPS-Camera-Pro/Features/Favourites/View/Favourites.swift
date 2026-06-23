//
//  Favourites.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI
import SwiftData

struct Favourites: View {
    @StateObject private var router = FavouritesRouterFlow()
    @Binding var presentSideMenu: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<StoredPhoto> { $0.isFavorite }, sort: \StoredPhoto.date, order: .reverse) private var favoritePhotos: [StoredPhoto]
    
    // Pinterest column distribution helper
    private var columns: [[StoredPhoto]] {
        var cols: [[StoredPhoto]] = [[], []]
        for (index, photo) in favoritePhotos.enumerated() {
            cols[index % 2].append(photo)
        }
        return cols
    }
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                FeatureNavBar(title: "Favourites") {
                    presentSideMenu = true
                }
                
                // MARK: - Content
                ScrollView {
                    if favoritePhotos.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                                .frame(height: 120)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple.opacity(0.4))
                            
                            Text("No favorites yet")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Tap the heart icon on any photo in All Photos to save it here.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(0..<2, id: \.self) { colIndex in
                                VStack(spacing: 12) {
                                    ForEach(columns[colIndex]) { photo in
                                        PhotoPinterestCard(photo: photo, onSelect: {
                                            router.navigate(.detail(photo))
                                        })
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(featureBackground)
            .navigationBarHidden(true)
            .navigationDestination(for: FavouritesFlow.self) { destination in
                destination.destinationView
            }
        }
    }
}
