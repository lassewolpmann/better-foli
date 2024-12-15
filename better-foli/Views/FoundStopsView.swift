//
//  SearchedStopsView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import SwiftData

struct FoundStopsView: View {
    let foliData: FoliDataClass
    let searchText: String
    
    @Query var foundStops: [StopData]
    
    init(foliData: FoliDataClass, searchText: String) {
        self.foliData = foliData
        self.searchText = searchText
        
        let predicate = #Predicate<StopData> { stop in
            return stop.name.localizedStandardContains(searchText)
        }
        
        _foundStops = Query(filter: predicate, sort: \.code)
    }
    
    var body: some View {
        ForEach(foundStops, id: \.code) { stop in
            NavigationLink {
                StopView(foliData: foliData, stopCode: stop.code)
            } label: {
                StopListPreviewView(stopCode: stop.code)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        List {
            FoundStopsView(foliData: FoliDataClass(), searchText: "")
        }
        .navigationTitle("Search")
    }
    .searchable(text: .constant(""))
}
