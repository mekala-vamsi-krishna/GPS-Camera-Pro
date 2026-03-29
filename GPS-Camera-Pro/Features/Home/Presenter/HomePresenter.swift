//
//  HomePresenter.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import Combine
import UIKit

final class HomePresenter: ObservableObject {
    
    // MARK: - Published Properties
    @Published var locationCard: LocationCardDetailDomain?
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isCaptureInProgress: Bool = false
    @Published var showDragHint: Bool = false
    @Published var showCaptureSuccess: Bool = false
    
    // MARK: - Interactor
    let interactor: HomeInteractor
    
    private var cancellables = Set<AnyCancellable>()
    private let dragHintKey = "hasSeenDragHint"
    
    // MARK: - Init
    init() {
        self.interactor = HomeInteractor()
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
    
    func capturePhoto(overlayRenderer: @escaping (UIImage) -> UIImage?) {
        isCaptureInProgress = true
        
        interactor.capturePhoto(overlayRenderer: overlayRenderer) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isCaptureInProgress = false
                if success {
                    self?.showCaptureSuccess = true
                    // Auto-dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.showCaptureSuccess = false
                    }
                } else {
                    self?.isError = true
                    self?.errorMessage = error ?? "Failed to capture photo"
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
