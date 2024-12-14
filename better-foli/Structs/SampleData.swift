//
//  SampleStopData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import Foundation
import SwiftUI
import SwiftData

let stops: [GtfsStop] = [
    GtfsStop(stop_code: "1", stop_name: "Turun satama (Silja)", stop_lat: 60.43497, stop_lon: 22.21966),
    GtfsStop(stop_code: "10", stop_name: "Sairashuoneenpuisto", stop_lat: 60.44419, stop_lon: 22.25233),
    GtfsStop(stop_code: "1000", stop_name: "Takamaantie", stop_lat: 60.43086, stop_lon: 22.27303)
]

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: StopData.self, TripData.self, configurations: config)
        
        for stop in stops {
            let stop = StopData(gtfsStop: stop)
            stop.isFavourite = true
            container.mainContext.insert(stop)
        }
        
        let sampleTrip = TripData(trip: GtfsTrip())
        container.mainContext.insert(sampleTrip)
        
        try container.mainContext.save()
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}
