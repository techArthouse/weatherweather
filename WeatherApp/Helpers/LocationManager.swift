//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Arturo Aguilar on 8/15/23.
//

import Foundation
import CoreLocation

// Standard implementation of LocationManager that exposes descriptive @published variables that clearly define output from locationservices
// so listeners can take appropriate action on user defined location services.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    @Published var isLocationAccessDenied: Bool = false
    
    // published to be observed in contentview or other bound classes to notify when we get location.
    @Published var userLocation: LocationWrapper?
    
    deinit {
        print("LocationManager is being deallocated")
    }

    override init() {
        super.init()
        self.locationManager.delegate = self

        // Only request permission if status is not determined
        if locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            // If permission has already been granted, start updating location immediately
            self.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            isLocationAccessDenied = true
        case .authorizedAlways, .authorizedWhenInUse:
            isLocationAccessDenied = false
            startUpdatingLocation()
        default:
            // Handle other cases if needed
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("LocationManager received location: \(location)")
        userLocation = LocationWrapper(location: location)
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// Wrapper used since location isn't equatable and this variable I wanted to use with swiftui's binding vars and methods.
// Specifically, this let's listen to changes in location in methods such as onChange for a reactive approach.
struct LocationWrapper: Equatable {
    let location: CLLocation

    static func ==(lhs: LocationWrapper, rhs: LocationWrapper) -> Bool {
        return lhs.location.coordinate.latitude == rhs.location.coordinate.latitude &&
               lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
    }
}
