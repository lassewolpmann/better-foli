//
//  FavouriteStopLabelView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI
import CoreLocation

struct FavouriteStopLabelView: View {
    let stop: StopData
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            HStack {
                Image(systemName: "parkingsign")
                Text(stop.code)
            }
            .font(.subheadline)
            .frame(width: 75, height: 25)
            .foregroundStyle(.orange)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.clear)
                    .stroke(.orange, lineWidth: 2)
            )
            
            Text(stop.name)
        }
    }
}

#Preview {
    FavouriteStopLabelView(stop: StopData(gtfsStop: GtfsStop()))
}
