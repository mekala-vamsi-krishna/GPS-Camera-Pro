//
//  HomeView.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var presenter = HomePresenter()
    @State private var selectedMode: CameraMode = .photo
    @State private var labelOffset: CGSize = .zero
    @State private var showCaptureFlash: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Camera Preview
                CameraPreviewView(captureSession: presenter.interactor.cameraService.captureSession)
                    .ignoresSafeArea()
                
                // Layer 2: Capture flash effect
                if showCaptureFlash {
                    Color.white
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                // Layer 3: Content overlay
                VStack(spacing: 0) {
                    // Top bar
                    CameraTopBar(
                        onMenuTap: { /* TODO */ },
                        onFilterTap: { /* TODO */ },
                        onFlashTap: { /* TODO */ },
                        onTimerTap: { /* TODO */ },
                        onAspectRatioTap: { /* TODO */ },
                        onSettingsTap: { /* TODO */ },
                        onToggleCameraTap: {
                            presenter.interactor.cameraService.toggleCamera()
                        }
                    )
                    .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 8)
                    
                    Spacer()
                    
                    // Geotag label (draggable)
                    if let locationCard = presenter.locationCard {
                        GeotagLabelView(
                            locationCard: locationCard,
                            labelOffset: $labelOffset,
                            onDragStarted: {
                                if presenter.showDragHint {
                                    presenter.dismissDragHint()
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Location permission prompt
                        locationPermissionPrompt
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Help button
                    HStack {
                        Spacer()
                        helpButton
                            .padding(.trailing, 16)
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // Bottom bar
                    CameraBottomBar(
                        selectedMode: $selectedMode,
                        onCapture: capturePhoto,
                        onStampTap: { /* TODO */ },
                        onMyPhotosTap: { /* TODO */ },
                        isCaptureInProgress: presenter.isCaptureInProgress
                    )
                }
                
                // Layer 4: Drag hint overlay
                DragHintOverlay(
                    isVisible: $presenter.showDragHint,
                    onDismiss: {
                        presenter.dismissDragHint()
                    }
                )
                
                // Capture success toast
                if presenter.showCaptureSuccess {
                    captureSuccessToast
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .statusBarHidden(true)
        .onAppear {
            presenter.onAppear()
        }
        .alert("Error", isPresented: $presenter.isError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(presenter.errorMessage)
        }
    }
}

// MARK: - SubViews
extension HomeView {
    
    /// Permission prompt when location is not yet granted
    private var locationPermissionPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .padding(16)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.15))
                )
            
            Text("This app needs location access")
                .font(.customFont(.medium, size: 16))
                .foregroundColor(.white)
            
            Button(action: {
                presenter.interactor.locationManager.requestPermission()
            }) {
                Text("Allow access")
                    .font(.customFont(.semibold, size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.0, green: 0.5, blue: 1.0),
                                             Color(red: 0.0, green: 0.6, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
        }
    }
    
    /// Help button (question mark in circle)
    private var helpButton: some View {
        Button(action: { /* TODO: show help */ }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// Success toast after capture
    private var captureSuccessToast: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 20))
                
                Text("Photo saved to gallery!")
                    .font(.customFont(.medium, size: 14))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75))
                    .shadow(color: .black.opacity(0.2), radius: 10)
            )
            .padding(.top, 60)
            
            Spacer()
        }
    }
}

// MARK: - Actions
extension HomeView {
    
    private func capturePhoto() {
        // Flash animation
        withAnimation(.easeInOut(duration: 0.1)) {
            showCaptureFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.1)) {
                showCaptureFlash = false
            }
        }
        
        // Capture with overlay compositing
        presenter.capturePhoto { capturedImage in
            return compositeOverlay(onto: capturedImage)
        }
    }
    
    /// Composites the geotag label view onto the captured camera image
    private func compositeOverlay(onto cameraImage: UIImage) -> UIImage? {
        guard let locationCard = presenter.locationCard else {
            return cameraImage
        }
        
        let imageSize = cameraImage.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { ctx in
            // Draw the original camera image
            cameraImage.draw(at: .zero)
            
            // Calculate label dimensions relative to the image
            let scale = imageSize.width / UIScreen.main.bounds.width
            let labelWidth = (UIScreen.main.bounds.width - 24) * scale
            let labelHeight: CGFloat = 100 * scale
            
            // Determine label position (default bottom-left, offset by drag)
            let defaultX: CGFloat = 12 * scale
            let defaultY: CGFloat = imageSize.height - labelHeight - 180 * scale
            let labelX = defaultX + labelOffset.width * scale
            let labelY = defaultY + labelOffset.height * scale
            
            let labelRect = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            
            // Draw label background
            let bgPath = UIBezierPath(roundedRect: labelRect, cornerRadius: 12 * scale)
            UIColor.black.withAlphaComponent(0.65).setFill()
            bgPath.fill()
            
            // Draw text content
            let textX = labelX + 12 * scale
            var currentY = labelY + 10 * scale
            
            // App name header
            let appNameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10 * scale),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let appNameStr = NSAttributedString(string: "📷 \(locationCard.appName)", attributes: appNameAttrs)
            appNameStr.draw(at: CGPoint(x: textX, y: currentY))
            currentY += 14 * scale
            
            // Location name (bold)
            let locationAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16 * scale),
                .foregroundColor: UIColor.white
            ]
            let locationStr = NSAttributedString(string: locationCard.locationName, attributes: locationAttrs)
            locationStr.draw(at: CGPoint(x: textX, y: currentY))
            currentY += 20 * scale
            
            // Sub-address
            if !locationCard.subAddress.isEmpty {
                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11 * scale),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.9)
                ]
                let subStr = NSAttributedString(string: locationCard.subAddress, attributes: subAttrs)
                subStr.draw(at: CGPoint(x: textX, y: currentY))
                currentY += 14 * scale
            }
            
            // Lat/Long
            let coordAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11 * scale),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            let coordStr = NSAttributedString(
                string: "Lat: \(String(format: "%.6f", locationCard.lat)), Long: \(String(format: "%.6f", locationCard.long))",
                attributes: coordAttrs
            )
            coordStr.draw(at: CGPoint(x: textX, y: currentY))
            currentY += 14 * scale
            
            // Date/time (green)
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12 * scale),
                .foregroundColor: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
            ]
            let dateStr = NSAttributedString(string: locationCard.dateTime, attributes: dateAttrs)
            dateStr.draw(at: CGPoint(x: textX, y: currentY))
            
            // Draw map snapshot on the right
            if let mapImage = locationCard.mapSnapshot {
                let mapSize = 70 * scale
                let mapX = labelX + labelWidth - mapSize - 12 * scale
                let mapY = labelY + (labelHeight - mapSize) / 2
                let mapRect = CGRect(x: mapX, y: mapY, width: mapSize, height: mapSize)
                
                let mapPath = UIBezierPath(roundedRect: mapRect, cornerRadius: 8 * scale)
                mapPath.addClip()
                mapImage.draw(in: mapRect)
            }
        }
    }
}

#Preview {
    HomeView()
}
