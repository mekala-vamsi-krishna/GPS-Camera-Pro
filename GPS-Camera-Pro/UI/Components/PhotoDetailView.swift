//
//  PhotoDetailView.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI
import SwiftData

struct PhotoDetailView: View {
    let photo: StoredPhoto
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            HStack {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                Text("Photo Details")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Delete button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.05, green: 0.04, blue: 0.08))
            
            // MARK: - Content
            ScrollView {
                VStack(spacing: 20) {
                    // Image container
                    if let imgData = photo.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(color: .purple.opacity(0.25), radius: 10)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    } else {
                        // Failure placeholder
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 300)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.exclamationmark")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Image data not found")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    }
                    
                    // Metadata Panel
                    VStack(alignment: .leading, spacing: 16) {
                        // Favorite toggle row
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("FAVORITE STATUS")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.purple.opacity(0.7))
                                Text(photo.isFavorite ? "Saved to Favourites" : "Not Favorited")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                    photo.isFavorite.toggle()
                                    try? modelContext.save()
                                }
                            }) {
                                Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(photo.isFavorite ? .red : .white.opacity(0.6))
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(12)
                        
                        // Date/Time Row
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(.purple)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Captured On")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                                Text(formatDate(photo.date))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Address Row
                        if let locName = photo.locationName, !locName.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 18))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Location")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.4))
                                    Text(locName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    if let sub = photo.subAddress, !sub.isEmpty {
                                        Text(sub)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.top, 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Latitude / Longitude
                        if let lat = photo.latitude, let long = photo.longitude {
                            HStack(spacing: 12) {
                                Image(systemName: "scope")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 18))
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Coordinates")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.4))
                                    Text("Lat: \(String(format: "%.6f", lat)), Long: \(String(format: "%.6f", long))")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(18)
                    .background(Color(red: 0.08, green: 0.07, blue: 0.12))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(featureBackground)
        .navigationBarHidden(true)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Photo"),
                message: Text("Are you sure you want to permanently delete this photo?"),
                primaryButton: .destructive(Text("Delete")) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    modelContext.delete(photo)
                    try? modelContext.save()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
