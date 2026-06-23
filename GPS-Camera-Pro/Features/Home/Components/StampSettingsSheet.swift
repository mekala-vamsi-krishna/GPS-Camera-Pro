//
//  StampSettingsSheet.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI

struct StampSettingsSheet: View {
    let locationCard: LocationCardDetailDomain?
    @Binding var stampShowMap: Bool
    @Binding var stampShowDateTime: Bool
    @Binding var stampShowCoordinates: Bool
    @Binding var stampShowAddress: Bool
    @Binding var stampThemeColor: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Title Bar
            HStack {
                Text("Stamp Customizer")
                    .font(.customFont(.bold, size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Preview
            if let locationCard = locationCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Live Preview")
                        .font(.customFont(.semibold, size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 24)
                    
                    GeotagLabelView(
                        locationCard: locationCard,
                        labelOffset: .constant(.zero),
                        showMap: stampShowMap,
                        showDateTime: stampShowDateTime,
                        showCoordinates: stampShowCoordinates,
                        showAddress: stampShowAddress,
                        themeColor: stampThemeColor
                    )
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
                }
            }
            
            // Scrollable settings list
            ScrollView {
                VStack(spacing: 20) {
                    // Custom Theme Colors
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stamp Color Theme")
                            .font(.customFont(.semibold, size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 12) {
                            ForEach(["Classic Black", "Ocean Blue", "Sunset Orange", "Mint Green"], id: \.self) { colorName in
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    stampThemeColor = colorName
                                }) {
                                    VStack(spacing: 6) {
                                        Circle()
                                            .fill(colorForName(colorName))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: stampThemeColor == colorName ? 2 : 0)
                                            )
                                        
                                        Text(colorName.replacingOccurrences(of: " ", with: "\n"))
                                            .font(.customFont(.regular, size: 10))
                                            .foregroundColor(stampThemeColor == colorName ? .white : .white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(stampThemeColor == colorName ? Color.white.opacity(0.1) : Color.clear)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 24)
                    
                    // Display Toggles
                    VStack(spacing: 12) {
                        Toggle(isOn: $stampShowMap) {
                            Label("Show Mini Map", systemImage: "map.fill")
                                .font(.customFont(.medium, size: 14))
                                .foregroundColor(.white)
                        }
                        .tint(AppTheme.Colors.primary)
                        
                        Toggle(isOn: $stampShowAddress) {
                            Label("Show Address", systemImage: "house.fill")
                                .font(.customFont(.medium, size: 14))
                                .foregroundColor(.white)
                        }
                        .tint(AppTheme.Colors.primary)
                        
                        Toggle(isOn: $stampShowCoordinates) {
                            Label("Show Coordinates", systemImage: "scope")
                                .font(.customFont(.medium, size: 14))
                                .foregroundColor(.white)
                        }
                        .tint(AppTheme.Colors.primary)
                        
                        Toggle(isOn: $stampShowDateTime) {
                            Label("Show Date & Time", systemImage: "calendar")
                                .font(.customFont(.medium, size: 14))
                                .foregroundColor(.white)
                        }
                        .tint(AppTheme.Colors.primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(
            Color(red: 0.08, green: 0.07, blue: 0.12)
                .ignoresSafeArea()
        )
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "Ocean Blue":
            return Color(red: 0.0, green: 0.35, blue: 0.7)
        case "Sunset Orange":
            return Color(red: 0.8, green: 0.25, blue: 0.1)
        case "Mint Green":
            return Color(red: 0.05, green: 0.45, blue: 0.25)
        default: // Classic Black
            return Color.black
        }
    }
}
