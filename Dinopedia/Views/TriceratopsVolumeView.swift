//
//  TriceratopVolumeView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TriceratopsVolumeView: View {

    var body: some View {
        RealityView { content in
            if let triceratops = try? await Entity(named: "Triceratops", in: realityKitContentBundle) {
                triceratops.position += [0, -1, 0]
                triceratops.scale *= 0.3
                
                if let anim = triceratops.availableAnimations.first {
                    triceratops.playAnimation(anim.repeat())
                }
                
                // You need to put the GroundingShadowComponent only on the entities that have the model component.
                // so you enumerate the USDZ file hierarchy and set the grounding shadow component on the right entity.
                triceratops.enumerateHierarchy { entity, stop in
                    if entity is ModelEntity{
                        entity.components.set(GroundingShadowComponent(castsShadow: true))
                    }
                }
                content.add(triceratops)
            }
        }
    }
}

#Preview {
    TriceratopsVolumeView()
}

