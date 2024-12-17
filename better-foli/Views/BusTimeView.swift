//
//  DepartureTimeView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct BusTimeView: View {
    let aimedTime: Int
    let expectedTime: Int
    let image: String
    
    var body: some View {
        let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedTime))
        let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedTime))
        let delay = Int(floor(expectedDate.timeIntervalSince(aimedDate) / 60))
        
        Label {
            HStack(alignment: .top, spacing: 2) {
                Text(aimedDate, style: .time)
                Text("\(delay >= 0 ? "+" : "")\(delay)")
                    .foregroundStyle(delay > 0 ? .red : .green)
                    .font(.footnote)
            }
        } icon: {
            Image(systemName: image)
        }
        .labelStyle(AlignedLabel())
    }
}

#Preview {
    let timestamp = Int(Date.now.timeIntervalSince1970)
    BusTimeView(aimedTime: timestamp, expectedTime: timestamp + 120, image: "arrow.left")
}
