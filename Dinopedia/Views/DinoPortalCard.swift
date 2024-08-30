//
//  DinoPortalCard.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/24/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct DinoPortalCard: View {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack() {
            RealityView { content in
                let world1 = Entity()
                world1.components.set(WorldComponent())
                let skybox1 = await createSkyboxEntity(texture: "skybox1")
                world1.addChild(skybox1)
                
                //Add dino
                if let dino = try? await Entity(named: "Triceratops", in: realityKitContentBundle) {
                    world1.addChild(dino)
                    dino.position += [0,-0.3, -0.5]
                    dino.scale *= 0.25
                    
                    //dino.transform.rotation = simd_quatf(angle: .pi/2, axis: [0,1,0])
                    if let anim = dino.availableAnimations.first {
                        dino.playAnimation(anim.repeat())
                    }
                    
                    // the size of the ibl should be very small. mostly hd...
                    if let environment = try? await EnvironmentResource(named: "PartiallyCloudySkybox") {
                        dino.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 1.5))
                        dino.components.set(ImageBasedLightReceiverComponent(imageBasedLight: dino))
                    }
                }
                
                content.add(world1)
                let world1Portal = createPortal(target: world1)
                world1Portal.transform.rotation = simd_quatf(angle: .pi/2, axis: [1,0,0])
                //world1Portal.position += [0,0,-0.19]
                content.add(world1Portal)
            }
            
            VStack {
                Button(action: {
                    openWindow(id: DinopediaApp.triceratopsVolume)
                }, label: {
                    Text("Triceratops")
                        .font(.largeTitle)
                        .padding()
                })
                .glassBackgroundEffect()
                .padding3D(.back, 1)
                
                Spacer()
                
                Text("The Triceratops was a large, herbivorous dinosaur with three distinct facial horns and a bony frill, known for its defensive capabilities during the Late Cretaceous period.")
                    .frame(maxWidth: 450)
                    .padding()
                    .glassBackgroundEffect()
                
            }
            .frame(depth: 600, alignment: .back)
            .frame(width: 600, height: 510)
        }
        .offset(z: 1)
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
    
    func createPortal(target: Entity) -> Entity {
        let portalMesh = MeshResource.generatePlane(width: 0.4, depth: 0.4, cornerRadius: 0.02)// meters
        let portal = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        portal.components.set(PortalComponent(target: target))
        return portal
    }
}

#Preview {
    DinoPortalCard()
}
