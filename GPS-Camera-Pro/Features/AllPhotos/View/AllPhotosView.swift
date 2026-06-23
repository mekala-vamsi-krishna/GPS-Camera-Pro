//
//  AllPhotosView.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI
import SwiftData

struct AllPhotosView: View {
    @StateObject private var router = AllPhotosRouterFlow()
    @Binding var presentSideMenu: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StoredPhoto.date, order: .reverse) private var photos: [StoredPhoto]
    
    // Pinterest column distribution helper
    private var columns: [[StoredPhoto]] {
        var cols: [[StoredPhoto]] = [[], []]
        for (index, photo) in photos.enumerated() {
            cols[index % 2].append(photo)
        }
        return cols
    }
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                FeatureNavBar(title: "All Photos") {
                    presentSideMenu = true
                }
                
                // MARK: - Content
                ScrollView {
                    if photos.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                                .frame(height: 120)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.purple.opacity(0.4))
                            
                            Text("No photos captured yet")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Photos you take with the geotag camera will show up here.")
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
            .navigationDestination(for: AllPhotosFlow.self) { destination in
                destination.destinationView
            }
        }
    }
}

// MARK: - Pinterest Photo Card View
struct PhotoPinterestCard: View {
    let photo: StoredPhoto
    let onSelect: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
                    if let imgData = photo.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white.opacity(0.2))
                            )
                    }
                    
                    // Heart Icon overlay
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            photo.isFavorite.toggle()
                            try? modelContext.save()
                        }
                    }) {
                        Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(photo.isFavorite ? .red : .white)
                            .padding(7)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 3)
                    }
                    .padding(8)
                }
                
                // Metadata overlay summary
                if let locName = photo.locationName, !locName.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(locName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(formatDate(photo.date))
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.08, green: 0.07, blue: 0.12).opacity(0.85))
                    .cornerRadius(8)
                    .padding(.top, 4)
                }
            }
            .background(Color.clear)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
