//
//  SearchView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 14.12.2024.
//

import SwiftUI
import SwiftData

enum SearchOption: String, CaseIterable {
    case busStop = "Bus Stops"
    case busLine = "Bus Lines"
}

struct SearchView: View {
    let foliData: FoliDataClass
    let locationManager: LocationManagerClass
    
    @State var searchOption: SearchOption = .busStop
    @State var searchText = ""
    @Query var allStops: [StopData]
    
    var searchPrompt: String {
        switch searchOption {
        case .busStop:
            return "Enter Stop Name or Number"
        case .busLine:
            return "Enter Line Name or Number"
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if (searchOption == .busStop) {
                    FoundStopsView(foliData: foliData, searchText: searchText)
                } else if (searchOption == .busLine) {
                    FoundLinesView(foliData: foliData, locationManager: locationManager, searchText: searchText)
                }
            }
            .navigationTitle("Search \(searchOption.rawValue)")
            .toolbar {
                Picker(selection: $searchOption) {
                    ForEach(SearchOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .searchable(text: $searchText, prompt: searchPrompt)
    }
}

#Preview(traits: .sampleData) {
    SearchView(foliData: FoliDataClass(), locationManager: LocationManagerClass())
}
