//
//  DragHintOverlay.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

/// A one-time overlay with a hand gesture icon teaching users to drag the geotag label
struct DragHintOverlay: View {
    @Binding var isVisible: Bool
    var onDismiss: () -> Void
    
    @State private var handOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        if isVisible {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissHint()
                    }
                
                VStack(spacing: 20) {
                    // Animated hand gesture
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: handOffset, y: handOffset * 0.5)
                        .animation(
                            Animation.easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                            value: handOffset
                        )
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    VStack(spacing: 6) {
                        Text("Drag to Reposition")
                            .font(.customFont(.bold, size: 18))
                            .foregroundColor(.white)
                        
                        Text("Move the location label anywhere on screen")
                            .font(.customFont(.regular, size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Tap to dismiss
                    Button(action: dismissHint) {
                        Text("Got it!")
                            .font(.customFont(.semibold, size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.top, 8)
                }
                .padding(40)
            }
            .opacity(opacity)
            .onAppear {
                handOffset = 30
            }
            .transition(.opacity)
        }
    }
    
    private func dismissHint() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isVisible = false
            onDismiss()
        }
    }
}
