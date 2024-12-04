//
//  DepartureTimeView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct DepartureTimeView: View {
    let aimedDeparture: Int
    let expectedDeparture: Int
    
    var body: some View {
        let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedDeparture))
        let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedDeparture))
        let delay = Int(floor(expectedDate.timeIntervalSince(aimedDate) / 60))
        
        Label {
            HStack(alignment: .top, spacing: 2) {
                Text(aimedDate, style: .time)
                Text("\(delay >= 0 ? "+" : "")\(delay)")
                    .foregroundStyle(delay > 0 ? .red : .primary)
                    .font(.footnote)
            }
        } icon: {
            Image(systemName: "arrow.left")
        }
        .labelStyle(AlignedLabel())
    }
}

#Preview {
    let timestamp = Int(Date.now.timeIntervalSince1970)
    DepartureTimeView(aimedDeparture: timestamp, expectedDeparture: timestamp + 120)
}
