//
//  BusStopLabelView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 2.12.2024.
//

import SwiftUI

struct BusStopLabelView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.orange)
            
            Image(systemName: "parkingsign.square")
                .foregroundStyle(.white)
                .padding(5)
        }
    }
}

#Preview {
    BusStopLabelView()
}
