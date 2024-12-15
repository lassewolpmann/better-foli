//
//  FoundLinesView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 15.12.2024.
//

import SwiftUI
import SwiftData

struct FoundLinesView: View {
    @Environment(\.modelContext) private var context
    @Query var foundLines: [RouteData]

    let foliData: FoliDataClass
    let searchText: String
    
    init(foliData: FoliDataClass, searchText: String) {
        self.foliData = foliData
        self.searchText = searchText
        
        let predicate = #Predicate<RouteData> { route in
            return route.longName.localizedStandardContains(searchText) || route.shortName.localizedStandardContains(searchText)
        }
        
        _foundLines = Query(filter: predicate, sort: \.routeID)
    }
    
    var body: some View {
        ForEach(foundLines, id: \.routeID) { route in
            HStack {
                Label {
                    Text(route.longName)
                } icon: {
                    Text(route.shortName)
                }
                
                Spacer()
                
                Button {
                    route.isFavourite.toggle()
                    
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: route.isFavourite ? "star.fill" : "star")
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        List {
            FoundLinesView(foliData: FoliDataClass(), searchText: "Satama")
        }
        .navigationTitle("Search")
    }
    .searchable(text: .constant("Satama"))
}
