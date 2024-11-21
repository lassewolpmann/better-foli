//
//  ContentView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 21.11.2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var stops: [Stop]?
    
    var body: some View {
        Map(bounds: .init(minimumDistance: 10, maximumDistance: 10000)) {
            if let stops {
                ForEach(stops, id: \.stop_code) { stop in
                    let stop_coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(stop.stop_lat), longitude: CLLocationDegrees(stop.stop_lon))
                    Marker(stop.stop_name, systemImage: "bus", coordinate: stop_coord)
                        .tint(.orange)
                }
            }
        }
        .mapControlVisibility(.hidden)
        .task {
            let dataClass = FoliDataClass()
            
            do {
                if let data = try await dataClass.loadStops() {
                    stops = data.array.filter({ stop in
                        stop.zone_id == "F\u{00d6}LI"
                    })
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
