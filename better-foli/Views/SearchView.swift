//
//  SearchView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    let foliData: FoliDataClass
    
    @State var searchText = ""
    @Query var allStops: [StopData]
    
    var body: some View {
        NavigationStack {
            List {
                FoundStopsView(foliData: foliData, searchText: searchText)
            }
            .navigationTitle("Search")
        }
        .searchable(text: $searchText)
    }
}

#Preview(traits: .sampleData) {
    SearchView(foliData: FoliDataClass())
}
