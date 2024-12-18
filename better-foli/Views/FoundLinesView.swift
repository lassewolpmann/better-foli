//
//  FoundLinesView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import SwiftData

struct FoundLinesView: View {
    @Query var foundLines: [RouteData]

    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    let searchText: String
    
    init(foliData: FoliDataClass, locationManager: LocationManagerClass, searchText: String) {
        self.foliData = foliData
        self.locationManager = locationManager
        self.searchText = searchText
        
        let predicate = #Predicate<RouteData> { route in
            return route.longName.localizedStandardContains(searchText) || route.shortName.localizedStandardContains(searchText)
        }
        
        _foundLines = Query(filter: predicate, sort: \.shortName)
    }
    
    var body: some View {
        ForEach(foundLines, id: \.routeID) { route in
            NavigationLink {
                BusLineView(foliData: foliData, locationManager: locationManager, route: route)
            } label: {
                BusLineLabel(customLabelText: route.customLabel, route: route, editMode: .inactive)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        List {
            FoundLinesView(foliData: FoliDataClass(), locationManager: LocationManagerClass(), searchText: "Satama")
        }
        .navigationTitle("Search")
    }
    .searchable(text: .constant("Satama"))
}
