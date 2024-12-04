//
//  FavouriteStopLabelView.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 4.12.2024.
//

import SwiftUI

struct FavouriteStopLabelView: View {
    var body: some View {
        Image(systemName: "star")
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
    FavouriteStopLabelView()
}
