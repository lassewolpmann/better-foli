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
    struct Result: Decodable {
        var recordedattime: Int = 1733224527
        var monitored: Bool = true
        
        var lineref: String = "1"
        var vehicleref: String? = "80026"
        
        var longitude: Double? = 22.26712
        var latitude: Double? = 60.44932
        
        var originaimedarrivaltime: Int? = 1733225340
        var originaimeddeparturetime: Int? = 1733227800
        
        var destinationdisplay: String = "Lentoasema"
        var destinationdisplay_sv: String?
        var destinationdisplay_en: String?
        
        var aimedarrivaltime: Int? = 1733225340
        var expectedarrivaltime: Int? = 1733225340

        var aimeddeparturetime: Int? = 1733225340
        var expecteddeparturetime: Int? = 1733225340
        
        var destinationaimedarrivaltime: Int? = 1733227800

        var delay: Int?
        var incongestion: Bool?
        
        var __tripref: String = "00010105__1001040100"
        var __routeref: String = "1"
    }
    
    var status: String
    var servertime: Int
    var result: [DetailedSiriStop.Result]
}
