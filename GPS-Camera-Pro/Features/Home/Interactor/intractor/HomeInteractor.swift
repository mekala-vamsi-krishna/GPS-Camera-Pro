//
//  HomeInteractor.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import Combine
import CoreLocation
import UIKit

final class HomeInteractor: ObservableObject {
    
    // MARK: - Services
    let locationManager = LocationManager()
    let cameraService = CameraService()
    
    // MARK: - Published
    @Published var locationCard: LocationCardDetailDomain?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("HomeInteractor initialized")
        setupBindings()
    }
    
    deinit {
        print("HomeInteractor deinitialized")
    }
    
    // MARK: - Public Methods
    
    func onAppear() {
        locationManager.requestPermission()
        cameraService.checkPermission()
    }
    
    func capturePhoto(overlayRenderer: @escaping (UIImage) -> UIImage?,
                      completion: @escaping (Bool, String?) -> Void) {
        cameraService.capturePhoto { [weak self] capturedImage in
            guard let self = self,
                  let capturedImage = capturedImage else {
                completion(false, "Failed to capture photo")
                return
            }
            
            // Composite overlay onto captured image
            guard let composited = overlayRenderer(capturedImage) else {
                completion(false, "Failed to composite overlay")
                return
            }
            
            // Save to gallery
            self.cameraService.saveImageToGallery(composited) { success, error in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error?.localizedDescription ?? "Failed to save photo")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Combine location updates into a LocationCardDetailDomain
        Publishers.CombineLatest4(
            locationManager.$coordinate,
            locationManager.$locationName,
            locationManager.$subAddress,
            locationManager.$formattedDateTime
        )
        .combineLatest(locationManager.$mapSnapshot)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] combined, mapSnapshot in
            let (coordinate, locationName, subAddress, dateTime) = combined
            guard let coordinate = coordinate else { return }
            
            let dto = LocationCardDetailDTO(
                lat: coordinate.latitude,
                long: coordinate.longitude,
                locationName: locationName,
                subAddress: subAddress,
                dateTime: dateTime,
                logo: "AppIcon",
                appName: Utils.shared.APP_NAME,
                mapSnapshot: mapSnapshot
            )
            
            self?.locationCard = dto.toDomain()
        }
        .store(in: &cancellables)
    }
}
