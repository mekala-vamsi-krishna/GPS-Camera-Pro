//
//  HomePresenter.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import Combine
import UIKit
import CoreLocation

final class HomePresenter: ObservableObject {
    
    // MARK: - Published Properties
    @Published var locationCard: LocationCardDetailDomain?
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isCaptureInProgress: Bool = false
    @Published var showDragHint: Bool = false
    @Published var showCaptureSuccess: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Stamp Settings (UserDefaults backed)
    @Published var stampShowMap: Bool {
        didSet { UserDefaults.standard.set(stampShowMap, forKey: "stampShowMap") }
    }
    @Published var stampShowDateTime: Bool {
        didSet { UserDefaults.standard.set(stampShowDateTime, forKey: "stampShowDateTime") }
    }
    @Published var stampShowCoordinates: Bool {
        didSet { UserDefaults.standard.set(stampShowCoordinates, forKey: "stampShowCoordinates") }
    }
    @Published var stampShowAddress: Bool {
        didSet { UserDefaults.standard.set(stampShowAddress, forKey: "stampShowAddress") }
    }
    @Published var stampThemeColor: String {
        didSet { UserDefaults.standard.set(stampThemeColor, forKey: "stampThemeColor") }
    }
    
    // MARK: - Interactor
    let interactor: HomeInteractor
    
    private var cancellables = Set<AnyCancellable>()
    private let dragHintKey = "hasSeenDragHint"
    
    // MARK: - Init
    init() {
        self.interactor = HomeInteractor()
        
        // Load settings from UserDefaults
        self.stampShowMap = UserDefaults.standard.object(forKey: "stampShowMap") as? Bool ?? true
        self.stampShowDateTime = UserDefaults.standard.object(forKey: "stampShowDateTime") as? Bool ?? true
        self.stampShowCoordinates = UserDefaults.standard.object(forKey: "stampShowCoordinates") as? Bool ?? true
        self.stampShowAddress = UserDefaults.standard.object(forKey: "stampShowAddress") as? Bool ?? true
        self.stampThemeColor = UserDefaults.standard.string(forKey: "stampThemeColor") ?? "Classic Black"
        
        print("HomePresenter initialized")
        setupBindings()
        checkDragHintStatus()
    }
    
    deinit {
        print("HomePresenter deinitialized")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        interactor.onAppear()
    }
    
    func onDisappear() {
        interactor.onDisappear()
    }
    
    func capturePhoto(overlayRenderer: @escaping (UIImage) -> UIImage?, completion: @escaping (CapturedPhoto?) -> Void) {
        isCaptureInProgress = true
        
        interactor.capturePhoto(overlayRenderer: overlayRenderer) { [weak self] compositedImage, location in
            DispatchQueue.main.async {
                self?.isCaptureInProgress = false
                if let image = compositedImage {
                    let captured = CapturedPhoto(image: image, location: location)
                    completion(captured)
                } else {
                    self?.isError = true
                    self?.errorMessage = "Failed to capture photo"
                    completion(nil)
                }
            }
        }
    }
    
    func dismissDragHint() {
        showDragHint = false
        UserDefaults.standard.set(true, forKey: dragHintKey)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Forward location card from interactor
        interactor.$locationCard
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationCard)
            
        // Forward location authorization status
        interactor.locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
        
        // Forward capture state
        interactor.cameraService.$isCaptureInProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$isCaptureInProgress)
    }
    
    private func checkDragHintStatus() {
        let hasSeen = UserDefaults.standard.bool(forKey: dragHintKey)
        showDragHint = !hasSeen
    }
}
