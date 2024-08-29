//
//  VelociraptorVolumeView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit

struct VelociraptorVolumeView: View {
    
    var body: some View {
        TimelineView(.animation) { context in
            Model3D(named: "Velociraptor") { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
                    .rotation3DEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 10 ), axis: .y)
            } placeholder: {
                ProgressView()
            }
        }
    }
}

#Preview {
    VelociraptorVolumeView()
}
