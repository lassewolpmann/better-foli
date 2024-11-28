//
//  LocationManagerClass.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 28.11.2024.
//

import Foundation
import CoreLocation

@Observable class LocationManagerClass {
    let manager = CLLocationManager()
    
    func requestAuthorization() {
        let currentAuthStatus = manager.authorizationStatus
        
        if (currentAuthStatus == .notDetermined) {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    var isAuthorized: Bool {
        return manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
    }
}
