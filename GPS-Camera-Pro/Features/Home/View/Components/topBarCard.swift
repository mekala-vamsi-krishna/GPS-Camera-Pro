//
//  topBarCard.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import SwiftUI

struct topBarCard: View {
    var tapOnCard: () -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: AppTheme.Radius.medium)
                .fill(AppTheme.Colors.background)
                .frame(height: 100)
                .onTapGesture(perform: tapOnCard)
        }
    }
}

