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
    private var snapshotTimer: Timer?
    
    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    deinit {
        snapshotTimer?.invalidate()
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
        snapshotTimer?.invalidate()
    }
    
    // MARK: - Private Methods
    private func updateDateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm"
        let dateStr = formatter.string(from: Date())
        
        let tz = TimeZone.current
        let tzAbbr = tz.abbreviation() ?? ""
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        let utcOffset = String(format: "UTC%@%02d:%02d", hours >= 0 ? "+" : "-", abs(hours), minutes)
        
        formattedDateTime = "\(dateStr) \(utcOffset)"
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        // Avoid geocoding the same spot repeatedly
        if let last = lastGeocodedLocation,
           last.distance(from: location) < 50 {
            return
        }
        lastGeocodedLocation = location
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.locationError = error.localizedDescription
                    return
                }
                
                guard let placemark = placemarks?.first else { return }
                
                // Build location name: "City, State, Country"
                var nameParts: [String] = []
                if let locality = placemark.locality {
                    nameParts.append(locality)
                }
                if let state = placemark.administrativeArea {
                    nameParts.append(state)
                }
                if let country = placemark.country {
                    nameParts.append(country)
                }
                self.locationName = nameParts.joined(separator: ", ")
                
                // Build sub-address: "SubLocality, SubAdministrativeArea..."
                var subParts: [String] = []
                if let subLocality = placemark.subLocality {
                    subParts.append(subLocality)
                }
                if let subAdmin = placemark.subAdministrativeArea {
                    subParts.append(subAdmin)
                }
                if subParts.isEmpty {
                    if let thoroughfare = placemark.thoroughfare {
                        subParts.append(thoroughfare)
                    }
                    if let subThoroughfare = placemark.subThoroughfare {
                        subParts.insert(subThoroughfare, at: 0)
                    }
                }
                self.subAddress = subParts.joined(separator: ", ")
                
                // Generate map snapshot
                self.generateMapSnapshot(for: location.coordinate)
            }
        }
    }
    
    private func generateMapSnapshot(for coordinate: CLLocationCoordinate2D) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        options.size = CGSize(width: 80, height: 80)
        options.mapType = .satellite
        options.showsBuildings = true
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { [weak self] snapshot, error in
            guard let self = self,
                  let snapshot = snapshot else { return }
            
            // Draw pin on snapshot
            let image = UIGraphicsImageRenderer(size: snapshot.image.size).image { ctx in
                snapshot.image.draw(at: .zero)
                
                let point = snapshot.point(for: coordinate)
                let pinSize: CGFloat = 20
                let pinRect = CGRect(
                    x: point.x - pinSize / 2,
                    y: point.y - pinSize,
                    width: pinSize,
                    height: pinSize
                )
                
                // Draw a red pin marker
                let pinColor = UIColor.red
                pinColor.setFill()
                let pinPath = UIBezierPath(ovalIn: CGRect(
                    x: pinRect.midX - 6,
                    y: pinRect.midY - 6,
                    width: 12,
                    height: 12
                ))
                pinPath.fill()
                
                // White inner circle
                UIColor.white.setFill()
                let innerPath = UIBezierPath(ovalIn: CGRect(
                    x: pinRect.midX - 3,
                    y: pinRect.midY - 3,
                    width: 6,
                    height: 6
                ))
                innerPath.fill()
            }
            
            DispatchQueue.main.async {
                self.mapSnapshot = image
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
        DispatchQueue.main.async {
            self.locationError = error.localizedDescription
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdating()
            case .denied, .restricted:
                self.locationError = "Location access denied. Please enable in Settings."
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}
