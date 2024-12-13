//
//  SampleStopData.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 13.12.2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SampleStopData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: StopData.self, configurations: config)
        
        let sampleStop = StopData(gtfsStop: GtfsStop())
        sampleStop.isFavourite = true
        
        container.mainContext.insert(sampleStop)
        try container.mainContext.save()
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleStopData: Self = .modifier(SampleStopData())
}
