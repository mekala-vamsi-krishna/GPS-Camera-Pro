//
//  PhotoConfirmView.swift
//  GPS-Camera-Pro
//
//  Created by User on 20/06/26.
//

import SwiftUI
import SwiftData

struct PhotoConfirmView: View {
    let capturedPhoto: CapturedPhoto
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: HomeRouterFlow
    
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            confirmNavBar
            confirmContent
            confirmActionButtons
        }
        .background(featureBackground)
        .navigationBarHidden(true)
        .overlay(successOverlay)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Save Failed"),
                message: Text(errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - Sub Views
extension PhotoConfirmView {
    
    private var confirmNavBar: some View {
        HStack {
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                router.navigateBack()
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
            
            Text("Confirm Save")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Centering placeholder
            Text("Back")
                .font(.system(size: 16))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.05, green: 0.04, blue: 0.08))
    }
    
    private var confirmContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                imagePreviewCard
                if let loc = capturedPhoto.location {
                    metadataPanel(loc)
                }
            }
        }
    }
    
    private var imagePreviewCard: some View {
        ZStack {
            Image(uiImage: capturedPhoto.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .shadow(color: .purple.opacity(0.2), radius: 10)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            
            if isSaving {
                Color.black.opacity(0.5)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.5)
                    Text("Saving Photo...")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
    }
    
    private func metadataPanel(_ loc: LocationCardDetailDomain) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.purple)
                    .font(.system(size: 18))
                Text(loc.locationName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            if !loc.subAddress.isEmpty {
                Text(loc.subAddress)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Divider()
                .background(Color.purple.opacity(0.2))
            
            coordinatesRow(loc)
        }
        .padding(16)
        .background(Color(red: 0.08, green: 0.07, blue: 0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func coordinatesRow(_ loc: LocationCardDetailDomain) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("LATITUDE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.purple.opacity(0.7))
                Text(String(format: "%.6f", loc.lat))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("LONGITUDE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.purple.opacity(0.7))
                Text(String(format: "%.6f", loc.long))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private var confirmActionButtons: some View {
        HStack(spacing: 16) {
            // Discard
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                router.navigateBack()
            }) {
                Text("Discard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(25)
            }
            
            // Save
            Button(action: {
                savePhotoAction()
            }) {
                Text("Save to Gallery")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color(red: 0.5, green: 0.18, blue: 0.88)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
            }
            .disabled(isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Color(red: 0.05, green: 0.04, blue: 0.08))
    }
    
    @ViewBuilder
    private var successOverlay: some View {
        if showSuccess {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    
                    Text("Photo Saved!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(Color(red: 0.1, green: 0.09, blue: 0.14).opacity(0.95))
                .cornerRadius(24)
                .shadow(color: .purple.opacity(0.3), radius: 20)
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Save Action
extension PhotoConfirmView {
    
    private func savePhotoAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isSaving = true
        let cameraService = CameraService()
        
        // 1. Save to Photo Library Gallery
        cameraService.saveImageToGallery(capturedPhoto.image) { success, error in
            if success {
                // 2. Save to SwiftData
                let jpegData = capturedPhoto.image.jpegData(compressionQuality: 0.9)
                let newPhoto = StoredPhoto(
                    date: Date(),
                    isFavorite: false,
                    latitude: capturedPhoto.location?.lat,
                    longitude: capturedPhoto.location?.long,
                    locationName: capturedPhoto.location?.locationName,
                    subAddress: capturedPhoto.location?.subAddress,
                    imageData: jpegData
                )
                
                modelContext.insert(newPhoto)
                
                do {
                    try modelContext.save()
                    
                    let notificationGen = UINotificationFeedbackGenerator()
                    notificationGen.notificationOccurred(.success)
                    
                    withAnimation {
                        isSaving = false
                        showSuccess = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        router.navigateToRoot()
                    }
                } catch {
                    isSaving = false
                    errorMessage = "Failed to save photo: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            } else {
                isSaving = false
                errorMessage = error?.localizedDescription ?? "Could not save image to camera roll."
                showErrorAlert = true
            }
        }
    }
}
