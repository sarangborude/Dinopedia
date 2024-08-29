//
//  TriceratopVolumeView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit

struct TriceratopsVolumeView: View {

    var body: some View {
        RealityView { content in
            if let triceratops = try? await Entity(named: "Triceratops") {
                triceratops.position += [0, -1, 0]
                triceratops.scale *= 0.3
                
                if let anim = triceratops.availableAnimations.first {
                    triceratops.playAnimation(anim.repeat())
                }
                triceratops.components.set(GroundingShadowComponent(castsShadow: true))
                content.add(triceratops)
            }
        }
    }
}

#Preview {
    TriceratopsVolumeView()
}
