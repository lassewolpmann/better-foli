//
//  ArrivalTimeView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct ArrivalTimeView: View {
    let aimedArrival: Int
    let expectedArrival: Int
    
    var body: some View {
        let aimedDate = Date(timeIntervalSince1970: TimeInterval(aimedArrival))
        let expectedDate = Date(timeIntervalSince1970: TimeInterval(expectedArrival))
        let delay = Int(floor(expectedDate.timeIntervalSince(aimedDate) / 60))
        
        Label {
            HStack(alignment: .top, spacing: 2) {
                Text(aimedDate, style: .time)
                Text("\(delay >= 0 ? "+" : "")\(delay)")
                    .foregroundStyle(delay > 0 ? .red : .green)
                    .font(.footnote)
            }
        } icon: {
            Image(systemName: "arrow.right")
        }
        .labelStyle(AlignedLabel())
    }
}

#Preview {
    let timestamp = Int(Date.now.timeIntervalSince1970)
    ArrivalTimeView(aimedArrival: timestamp, expectedArrival: timestamp + 120)
}
