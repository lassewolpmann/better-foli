//
//  SiriStops.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import Foundation

struct SiriStop: Decodable {
    // https://data.foli.fi/siri/sm/pretty
    var stop_name: String
}

struct DetailedSiriStop: Decodable {
    // https://data.foli.fi/siri/sm/1/pretty
    struct Result: Decodable, Hashable {
        var recordedattime: Int
        var monitored: Bool
        
        var lineref: String
        var vehicleref: String?
        
        var longitude: Double?
        var latitude: Double?
        
        var originaimedarrivaltime: Int?
        var originaimeddeparturetime: Int?
        
        var destinationdisplay: String
        var destinationdisplay_sv: String?
        var destinationdisplay_en: String?
        
        var aimedarrivaltime: Int?
        var expectedarrivaltime: Int?

        var aimeddeparturetime: Int?
        var expecteddeparturetime: Int?
        
        var destinationaimedarrivaltime: Int?

        var delay: Int?
        var incongestion: Bool?
        
        var __tripref: String?
        var __routeref: String?
    }
    
    var status: String
    var servertime: Int
    var result: [DetailedSiriStop.Result]
}
