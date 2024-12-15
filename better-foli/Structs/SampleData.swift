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

let shapes: [GtfsShape] = [
    GtfsShape(lat: 60.51109, lon: 22.27422, traveled: 0),
    GtfsShape(lat: 60.51104, lon: 22.27416, traveled: 6),
    GtfsShape(lat: 60.511, lon: 22.27411, traveled: 11),
    GtfsShape(lat: 60.51081, lon: 22.27389, traveled: 36),
    GtfsShape(lat: 60.5105, lon: 22.27353, traveled: 75),
    GtfsShape(lat: 60.51047, lon: 22.27349, traveled: 79),
    GtfsShape(lat: 60.51004, lon: 22.27348, traveled: 127),
    GtfsShape(lat: 60.50979, lon: 22.27347, traveled: 155),
    GtfsShape(lat: 60.50959, lon: 22.27359, traveled: 178),
    GtfsShape(lat: 60.50936, lon: 22.27387, traveled: 208),
    GtfsShape(lat: 60.5092, lon: 22.27413, traveled: 230)
]

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: StopData.self, TripData.self, ShapeData.self, RouteData.self, configurations: config)
        
        for stop in stops {
            let stop = StopData(gtfsStop: stop)
            stop.isFavourite = true
            container.mainContext.insert(stop)
        }
        
        let sampleTrip = TripData(trip: GtfsTrip(trip_id: "00010036__1001050100", trip_headsign: "Satama", shape_id: "434", route_id: "1"))
        container.mainContext.insert(sampleTrip)
        
        let sampleShape = ShapeData(shapeID: "434", shapes: shapes)
        container.mainContext.insert(sampleShape)
        
        let sampleRoute = RouteData(route: GtfsRoute(route_id: "1", route_short_name: "1", route_long_name: "Lentoasema-Satama"))
        sampleRoute.isFavourite = true
        container.mainContext.insert(sampleRoute)
        
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
