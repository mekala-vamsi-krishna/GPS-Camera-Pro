//
//  CameraBottomBar.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

/// Bottom bar with mode selector and capture button
struct CameraBottomBar: View {
    @Binding var selectedMode: CameraMode
    var onCapture: () -> Void
    var onStampTap: () -> Void
    var onMyPhotosTap: () -> Void
    var isCaptureInProgress: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Mode selector
            modeSelector
            
            // Capture bar
            captureBar
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Mode Selector
    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(CameraMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(mode.title)
                            .font(.customFont(selectedMode == mode ? .bold : .regular, size: 12))
                            .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                        
                        if mode.isPremium {
                            Text("👑")
                                .font(.system(size: 10))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selectedMode == mode
                        ? Capsule().fill(AppTheme.Colors.primary.opacity(0.8))
                        : Capsule().fill(Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    // MARK: - Capture Bar
    private var captureBar: some View {
        HStack {
            // Stamp button
            Button(action: onStampTap) {
                VStack(spacing: 4) {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    Text("Stamp")
                        .font(.customFont(.regular, size: 10))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Capture button
            Button(action: onCapture) {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 3)
                        .frame(width: 72, height: 72)
                    
                    // Inner circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: selectedMode == .photo
                                    ? [.white, .white]
                                    : [AppTheme.Colors.primary, AppTheme.Colors.primary.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    if isCaptureInProgress {
                        ProgressView()
                            .tint(.gray)
                    }
                }
            }
            .disabled(isCaptureInProgress)
            
            // Right side: secondary capture / My Photos
            Button(action: onMyPhotosTap) {
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "photo.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    Text("My Photos")
                        .font(.customFont(.regular, size: 10))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Camera Mode
enum CameraMode: CaseIterable {
  //  case timelapse
    case photo
   // case video
   // case qrCode
    
    var title: String {
        switch self {
      //  case .timelapse: return "TIMELAPSE"
        case .photo: return "PHOTO"
      //  case .video: return "VIDEO"
      //  case .qrCode: return "QR CODE"
        }
    }
    
    var isPremium: Bool {
        switch self {
       // case .timelapse, .video: return true
        default: return false
        }
    }
}
