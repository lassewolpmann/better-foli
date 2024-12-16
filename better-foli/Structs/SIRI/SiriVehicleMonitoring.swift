//
//  SiriVehicleMonitoring.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 2.12.2024.
//

import Foundation

struct SiriVehicleMonitoring: Decodable {
    // https://data.foli.fi/siri/vm/pretty
    
    struct Result: Decodable {
        struct Vehicle: Decodable {
            struct OnwardCalls: Codable {
                var stoppointname: String
                var stoppointref: String
                var aimedarrivaltime: Int
                var expectedarrivaltime: Int
                var aimeddeparturetime: Int
                var expecteddeparturetime: Int
            }
            
            var percentage: Double?
            var lineref: String? = "1"
            var vehicleref: String?
            var originname: String?
            var destinationname: String? = "Turun satama (Silja)"
            var monitored: Bool? = true
            var longitude: Double? = 22.26685
            var latitude: Double? = 60.45402
            var next_aimedarrivaltime: Int?
            var next_expectedarrivaltime: Int?
            var next_aimeddeparturetime: Int?
            var next_expecteddeparturetime: Int?
            var onwardcalls: [OnwardCalls]? = []
            var __tripref: String? = "00010001__1001030100"
            var __routeref: String? = "1"
        }
        
        var vehicles: [String: Vehicle] = [:]
    }
    
    var status: String = "OK"
    var servertime: Int = 0
    var result: SiriVehicleMonitoring.Result
}
