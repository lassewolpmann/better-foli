//
//  HorizontalAlignedLabel.swift
//  better-foli
//
//  Created by Lasse Wolpmann on 5.12.2024.
//

import Foundation
import SwiftUI

struct AlignedLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
            configuration.title
        }
        .multilineTextAlignment(.leading)
    }
}
