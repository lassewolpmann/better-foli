//
//  SampleStopData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: StopData.self, TripData.self, configurations: config)
        
        let sampleStop = StopData(gtfsStop: GtfsStop())
        let sampleTrip = TripData(trip: GtfsTrip())
        sampleStop.isFavourite = true
        
        container.mainContext.insert(sampleStop)
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
