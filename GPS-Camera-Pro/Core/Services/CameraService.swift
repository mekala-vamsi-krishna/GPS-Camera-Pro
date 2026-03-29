//
//  CameraService.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import Combine

final class CameraService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var capturedImage: UIImage?
    @Published var isCaptureInProgress: Bool = false
    @Published var permissionGranted: Bool = false
    @Published var cameraError: String?
    
    // MARK: - Session
    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var sessionIsConfigured = false
    
    // Completion callback for photo capture
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    // MARK: - Init
    override init() {
        super.init()
    }
    
    deinit {
        stopSession()
        print("CameraService deinitialized")
    }
    
    // MARK: - Public Methods
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
            cameraError = "Camera access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }
    
    func startSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard !isCaptureInProgress else { return }
        
        DispatchQueue.main.async {
            self.isCaptureInProgress = true
        }
        
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleCamera() {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        captureSession.beginConfiguration()
        
        // Remove existing inputs
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        // Add new camera
        guard let camera = getCamera(position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Save to Photos
    
    func saveImageToGallery(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "CameraService", code: -1,
                                             userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(
                    with: .photo,
                    data: image.jpegData(compressionQuality: 0.9)!,
                    options: nil
                )
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSession() {
        guard !sessionIsConfigured else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        // Add camera input
        guard let camera = getCamera(position: currentCameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            cameraError = "Unable to access camera"
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        sessionIsConfigured = true
        startSession()
    }
    
    private func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        DispatchQueue.main.async {
            self.isCaptureInProgress = false
        }
        
        if let error = error {
            DispatchQueue.main.async {
                self.cameraError = error.localizedDescription
                self.photoCaptureCompletion?(nil)
                self.photoCaptureCompletion = nil
            }
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            DispatchQueue.main.async {
                self.photoCaptureCompletion?(nil)
                self.photoCaptureCompletion = nil
            }
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.photoCaptureCompletion?(image)
            self.photoCaptureCompletion = nil
        }
    }
}
