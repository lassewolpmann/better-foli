//
//  BusStopLabelView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 2.12.2024.
//

import SwiftUI

struct BusStopLabelView: View {
    let isFavourite: Bool
    
    var body: some View {
        Image(systemName: isFavourite ? "star" : "parkingsign")
            .foregroundStyle(.orange)
            .padding(5)
            .background(
                Circle()
                    .fill(.white)
                    .stroke(.orange, lineWidth: 2)
            )
    }
}

#Preview {
    BusStopLabelView(isFavourite: false)
}
