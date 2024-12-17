//
//  FavouriteLineLabel.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 17.12.2024.
//

import SwiftUI

struct FavouriteLineLabel: View {
    @State private var customLabelText: String = ""
    
    let route: RouteData
    let editMode: EditMode
    
    var body: some View {
        HStack {
            Text(route.shortName)
                .bold()
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(route.longName)
                
                if (editMode == .inactive) {
                    if (!route.customLabel.isEmpty) {
                        Text(route.customLabel)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                } else if (editMode == .active) {
                    TextField(route.customLabel.isEmpty ? "Custom Label" : route.customLabel, text: $customLabelText)
                        .onSubmit {
                            route.customLabel = customLabelText
                        }
                }
            }
        }
    }
}

#Preview {
    List {
        FavouriteLineLabel(route: RouteData(route: GtfsRoute()), editMode: .active)
    }
}
