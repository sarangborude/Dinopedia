//
//  ImmersiveView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/24/24.
//

import SwiftUI
import RealityKit

@MainActor
struct ImmersiveBrachiosaurusView: View {
    
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        RealityView { content, attachments in
            if let brachio = try? await Entity(named: "Brachiosaurus") {
                
                brachio.position += [0, 0, -2]
                brachio.scale *= 10
                brachio.transform.rotation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                content.add(brachio)

                // the size of the ibl should be very small. mostly hd...
                if let environment = try? await EnvironmentResource(named: "PartiallyCloudySkybox") {
                    print("environment ibl loaded")
                    brachio.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
                    brachio.components.set(ImageBasedLightReceiverComponent(imageBasedLight: brachio))
                }
                
                print(brachio.availableAnimations.count)
                let anim = brachio.availableAnimations[0]
                brachio.playAnimation(anim.repeat())
            }
            
            let skybox = await createSkyboxEntity(texture: "skybox2")
            content.add(skybox)
            
            if let infoCard = attachments.entity(for: "BrachioInfo") {
                content.add(infoCard)
                infoCard.position += [2, 0.5, -1.7] // meters
            }
            
        } update: { content, attachments in
            
        } attachments: {
            Attachment(id: "BrachioInfo") {
                VStack {
                    Text("The Brachiosaurus was a massive, long-necked herbivorous dinosaur that lived during the Late Jurassic period, around 154 to 153 million years ago. Characterized by its unique posture with forelimbs longer than its hind limbs, it could reach towering heights to browse on vegetation that other herbivores couldn’t access. With its long neck and small head, the Brachiosaurus is often depicted as one of the most iconic dinosaurs, representing the classic image of a giant, gentle giant roaming ancient forests. Its enormous size, combined with a relatively slow metabolism, likely helped it avoid most predators.")
                        .font(.largeTitle)
                        .frame(width: 700)
                        //.padding(20)
                   
                    
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
    }
    
    func createSkyboxEntity(texture: String) async -> Entity {
        guard let resource = try? await TextureResource(named: texture) else {
            fatalError("Unable to load the skybox")
        }
        
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        
        let entity = Entity()
        entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
        entity.scale *= .init(x: -1, y:1, z:1)
        return entity
    }
    
}

#Preview(immersionStyle: .mixed) {
    ImmersiveBrachiosaurusView()
}
