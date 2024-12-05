//
//  FavouriteStopLabelView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct FavouriteStopLabelView: View {
    let stop: GtfsStop
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            HStack {
                Image(systemName: "parkingsign")
                Text(stop.stop_code)
            }
            .font(.subheadline)
            .frame(width: 75, height: 25)
            .foregroundStyle(.orange)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.clear)
                    .stroke(.orange, lineWidth: 2)
            )
            
            Text(stop.stop_name)
        }
    }
}

#Preview {
    FavouriteStopLabelView(stop: GtfsStop())
}
