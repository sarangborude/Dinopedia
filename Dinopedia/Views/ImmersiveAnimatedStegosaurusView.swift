//
//  ImmersiveAnimatedStegosaurusView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveAnimatedStegosaurusView: View {
    
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openWindow) var openWindow
    
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        RealityView { content, attachments in
            if let stego = try? await Entity(named: "Stegosaurus", in: realityKitContentBundle) {
                
                stego.position += [0, 0, -2]
                stego.transform.rotation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                content.add(stego)
                
                //print(stego.availableAnimations.count)
                let anim = stego.availableAnimations[1]
                stego.playAnimation(anim.repeat())
                
                if let infoCard = attachments.entity(for: "StegoInfo") {
                    content.add(infoCard)
                    infoCard.position += [1, 0.5, -1.7] // meters
                }
            }
        } update: { content, attachments in
            
        } attachments: {
            Attachment(id: "StegoInfo") {
                VStack {
                    Text("The Stegosaurus was a large, herbivorous dinosaur that lived during the Late Jurassic period, about 155 to 150 million years ago. It is easily recognized by the distinctive double row of large, plate-like structures along its back and the spiked tail, known as the thagomizer, which it likely used for defense against predators. Despite its formidable appearance, the Stegosaurus had a small brain relative to its body size, indicating it was not as intelligent as some other dinosaurs.")
                        .font(.largeTitle)
                        .frame(width: 700)
                    Button(action: {
                        Task {
                            await dismissImmersiveSpace()
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .padding()
                    })
                }
                .padding(50)
                .glassBackgroundEffect()
            }
        }
        .onAppear {
            dismissWindow(id: DinopediaApp.homeView)
        }
        .onDisappear {
            openWindow(id: DinopediaApp.homeView)
        }
    }
}

#Preview {
    ImmersiveAnimatedStegosaurusView()
}
