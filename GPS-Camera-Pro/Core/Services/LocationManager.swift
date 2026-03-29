//
//  LocationManager.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var locationName: String = "Fetching location..."
    @Published var subAddress: String = ""
    @Published var formattedDateTime: String = ""
    @Published var mapSnapshot: UIImage?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    // MARK: - Private
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var lastGeocodedLocation: CLLocation?
    private var currentSnapshotter: MKMapSnapshotter?
    private var lastSnapshotCoordinate: CLLocationCoordinate2D?
    
    // Throttle: minimum seconds between geocode calls
    private var lastGeocodeTime: Date = .distantPast
    private let geocodeThrottleInterval: TimeInterval = 60 // Increase to 60s
    
    // Reused objects to save memory
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yy HH:mm"
        return f
    }()
    
    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100 // Update every 100 meters to reduce frequency
    }
    
    deinit {
        currentSnapshotter?.cancel()
        print("LocationManager deinitialized")
    }
    
    // MARK: - Public Methods
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        currentSnapshotter?.cancel()
    }
    
    // MARK: - Private Methods
    private func updateDateTime() {
        let dateStr = Self.formatter.string(from: Date())
        
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        let utcOffset = String(format: "UTC%@%02d:%02d", hours >= 0 ? "+" : "-", abs(hours), minutes)
        
        let newDateTime = "\(dateStr) \(utcOffset)"
        if formattedDateTime != newDateTime {
            formattedDateTime = newDateTime
        }
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        // Throttle: skip if called too recently
        let now = Date()
        guard now.timeIntervalSince(lastGeocodeTime) >= geocodeThrottleInterval else {
            return
        }
        
        // Skip if we haven't moved far enough
        if let last = lastGeocodedLocation,
           last.distance(from: location) < 100 {
            return
        }
        
        lastGeocodedLocation = location
        lastGeocodeTime = now
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocode error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else { return }
                
                // Build location name
                var nameParts: [String] = []
                if let locality = placemark.locality { nameParts.append(locality) }
                if let state = placemark.administrativeArea { nameParts.append(state) }
                if let country = placemark.country { nameParts.append(country) }
                let newName = nameParts.joined(separator: ", ")
                if self.locationName != newName { self.locationName = newName }
                
                // Build sub-address
                var subParts: [String] = []
                if let subLocality = placemark.subLocality { subParts.append(subLocality) }
                if let subAdmin = placemark.subAdministrativeArea { subParts.append(subAdmin) }
                if subParts.isEmpty {
                    if let thoroughfare = placemark.thoroughfare { subParts.append(thoroughfare) }
                    if let subThor = placemark.subThoroughfare { subParts.insert(subThor, at: 0) }
                }
                let newSub = subParts.joined(separator: ", ")
                if self.subAddress != newSub { self.subAddress = newSub }
                
                // Generate map snapshot
                self.generateMapSnapshotIfNeeded(for: location.coordinate)
            }
        }
    }
    
    private func generateMapSnapshotIfNeeded(for coordinate: CLLocationCoordinate2D) {
        // Higher threshold for map updates: 200m
        if let last = lastSnapshotCoordinate {
            let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
            let newLoc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if lastLoc.distance(from: newLoc) < 200 && mapSnapshot != nil {
                return
            }
        }
        
        currentSnapshotter?.cancel()
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        // Smaller snapshot size to save memory
        options.size = CGSize(width: 60, height: 60)
        options.mapType = .satellite
        
        let snapshotter = MKMapSnapshotter(options: options)
        currentSnapshotter = snapshotter
        
        snapshotter.start { [weak self] snapshot, error in
            guard let self = self,
                  let snapshot = snapshot,
                  self.currentSnapshotter === snapshotter else {
                return
            }
            
            // Draw pin on snapshot
            let image = UIGraphicsImageRenderer(size: snapshot.image.size).image { _ in
                snapshot.image.draw(at: .zero)
                let point = snapshot.point(for: coordinate)
                
                UIColor.red.setFill()
                UIBezierPath(ovalIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)).fill()
                
                UIColor.white.setFill()
                UIBezierPath(ovalIn: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)).fill()
            }
            
            DispatchQueue.main.async {
                self.lastSnapshotCoordinate = coordinate
                self.mapSnapshot = image
                self.currentSnapshotter = nil
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.coordinate = location.coordinate
            self.updateDateTime()
            self.reverseGeocode(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently handle errors unless critical
        print("LocationManager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.startUpdating()
            }
        }
    }
}
