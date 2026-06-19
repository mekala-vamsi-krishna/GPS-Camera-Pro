//
//  GeotagLabelView.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

/// The draggable geotag info card overlay that displays location details + mini map
struct GeotagLabelView: View {
    let locationCard: LocationCardDetailDomain
    @Binding var labelOffset: CGSize
    var onDragStarted: (() -> Void)?
    
    @State private var dragAmount: CGSize = .zero
    
    var body: some View {
        labelContent
            .offset(x: labelOffset.width + dragAmount.width,
                    y: labelOffset.height + dragAmount.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragAmount = value.translation
                        onDragStarted?()
                    }
                    .onEnded { value in
                        labelOffset = CGSize(
                            width: labelOffset.width + value.translation.width,
                            height: labelOffset.height + value.translation.height
                        )
                        dragAmount = .zero
                    }
            )
    }
    
    // MARK: - Label Content
    private var labelContent: some View {
        HStack(alignment: .top, spacing: 8) {
            // Left side: location info
            VStack(alignment: .leading, spacing: 3) {
                // App header
                appHeader
                
                // Location name
                Text(locationCard.locationName)
                    .font(.customFont(.bold, size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Sub-address
                if !locationCard.subAddress.isEmpty {
                    Text(locationCard.subAddress)
                        .font(.customFont(.regular, size: 11))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                
                // Lat/Long
                Text("Lat: \(String(format: "%.6f", locationCard.lat)), Long: \(String(format: "%.6f", locationCard.long))")
                    .font(.customFont(.regular, size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                // Date/Time
                Text(locationCard.dateTime)
                    .font(.customFont(.semibold, size: 12))
                    .foregroundColor(AppTheme.Colors.success)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right side: mini map snapshot
            if let mapImage = locationCard.mapSnapshot {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: mapImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Small pin icon
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.primary)
                        .background(Circle().fill(.white).frame(width: 14, height: 14))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.65))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.horizontal, 12)
    }
    
    // MARK: - App Header
    private var appHeader: some View {
        HStack(spacing: 4) {
            // App icon
            Image(systemName: "camera.fill")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.primary.opacity(0.7))
                )
            
            Text(locationCard.appName)
                .font(.customFont(.regular, size: 10))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
