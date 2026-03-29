//
//  CameraPreviewView.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI
import AVFoundation

/// UIViewRepresentable that wraps AVCaptureVideoPreviewLayer for live camera preview
struct CameraPreviewView: UIViewRepresentable {
    let captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer.session = captureSession
        view.previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // Session updates are handled externally
    }
}

/// Custom UIView that manages the AVCaptureVideoPreviewLayer layout
class CameraPreviewUIView: UIView {
    
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(previewLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
