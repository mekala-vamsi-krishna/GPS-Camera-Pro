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
    
    func onDisappear() {
        locationManager.stopUpdating()
        cameraService.stopSession()
    }
    
    func capturePhoto(overlayRenderer: @escaping (UIImage) -> UIImage?,
                      completion: @escaping (Bool, String?) -> Void) {
        print(" HomeInteractor: capturePhoto called")
        cameraService.capturePhoto { [weak self] capturedImage in
            guard let self = self,
                  let capturedImage = capturedImage else {
                print("❌ HomeInteractor: capturedImage is nil")
                completion(false, "Failed to capture photo")
                return
            }
            
            print(" HomeInteractor: got captured image \(capturedImage.size)")
            
            // Composite overlay onto captured image
            guard let composited = overlayRenderer(capturedImage) else {
                print("❌ HomeInteractor: overlay compositing failed")
                completion(false, "Failed to composite overlay")
                return
            }
            
            print(" HomeInteractor: composited image \(composited.size), saving to gallery...")
            
            // Save to gallery
            self.cameraService.saveImageToGallery(composited) { success, error in
                if success {
                    print(" HomeInteractor: photo saved to gallery!")
                    completion(true, nil)
                } else {
                    print("❌ HomeInteractor: save failed - \(error?.localizedDescription ?? "unknown")")
                    completion(false, error?.localizedDescription ?? "Failed to save photo")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Optimization: Throttled and deduplicated Combine pipeline
        Publishers.CombineLatest4(
            locationManager.$coordinate.removeDuplicates { $0?.latitude == $1?.latitude && $0?.longitude == $1?.longitude },
            locationManager.$locationName.removeDuplicates(),
            locationManager.$subAddress.removeDuplicates(),
            locationManager.$formattedDateTime.removeDuplicates()
        )
        .combineLatest(locationManager.$mapSnapshot.removeDuplicates())
        .throttle(for: .seconds(3), scheduler: DispatchQueue.main, latest: true)
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
            
            let newDomain = dto.toDomain()
            // Only update if something actually changed
            if self?.locationCard?.locationName != newDomain.locationName || 
                self?.locationCard?.dateTime != newDomain.dateTime || 
                self?.locationCard?.mapSnapshot != newDomain.mapSnapshot {
                self?.locationCard = newDomain
            }
        }
        .store(in: &cancellables)
    }
}
