//
//  SiriVehicleMonitoring.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 2.12.2024.
//

import Foundation

struct SiriVehicleMonitoring: Decodable {
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
            var lineref: String?
            var vehicleref: String?
            var originname: String?
            var destinationname: String?
            var monitored: Bool?
            var longitude: Double?
            var latitude: Double?
            var next_aimedarrivaltime: Int?
            var next_expectedarrivaltime: Int?
            var next_aimeddeparturetime: Int?
            var next_expecteddeparturetime: Int?
            var onwardcalls: [OnwardCalls]?
            var __tripref: String?
            var __routeref: String?
        }
        
        var vehicles: [String: Vehicle]
    }
    
    var status: String
    var servertime: Int
    var result: SiriVehicleMonitoring.Result
}
