//
//  VelociraptorVolumeView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct VelociraptorVolumeView: View {
    
    var body: some View {
        TimelineView(.animation) { context in
            Model3D(named: "Velociraptor", bundle: realityKitContentBundle) { model in
                model
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.6)
                    .rotation3DEffect(.degrees(context.date.timeIntervalSinceReferenceDate * 10 ), axis: .y)
            } placeholder: {
                ProgressView()
            }
            //.frame(depth: 5000, alignment: .center)
            //.frame(width: 5000, height: 5000)
        }
    }
}

#Preview {
    VelociraptorVolumeView()
}
