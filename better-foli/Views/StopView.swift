//
//  StopView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 30.11.2024.
//

import SwiftUI
import SwiftData

struct StopView: View {
    @Environment(\.modelContext) private var context

    let foliData: FoliDataClass
    let stopCode: String
    
    @State var detailedStop: DetailedSiriStop?
    @Query var stops: [StopData]
    var stop: StopData? { stops.first }
    
    init(foliData: FoliDataClass, stopCode: String) {
        self.foliData = foliData
        self.stopCode = stopCode
        
        _stops = Query(filter: #Predicate<StopData> { $0.code == stopCode })
    }
    
    var body: some View {
        if let detailedStop, let stop {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(detailedStop.result, id: \.self) { upcomingBus in
                            UpcomingBusView(foliData: foliData, upcomingBus: upcomingBus, selectedStopCode: stop.code)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .navigationTitle("\(stop.name) - \(stop.code)")
                .toolbar {
                    Button {
                        stop.isFavourite.toggle()
                        
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                    } label: {
                        Label {
                            Text("Save to Favourites")
                        } icon: {
                            Image(systemName: stop.isFavourite ? "star.fill" : "star")
                        }
                    }
                }
            }
        } else {
            ProgressView("Loading data...")
                .task {
                    do {
                        guard let stop else { return }
                        detailedStop = try await foliData.getSiriStopData(stop: stop)
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

#Preview(traits: .sampleData) {
    StopView(foliData: FoliDataClass(), stopCode: "1")
}
