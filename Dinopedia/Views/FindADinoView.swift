//
//  FindADinoView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/26/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct FindADinoView: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State private var nameOfDino = ""
    
    @State private var dinoDescription = ""
    
    let dinoDescriptions = [
        "Brachiosaurus" : "The Brachiosaurus was a massive, long-necked herbivorous dinosaur that lived during the Late Jurassic period, around 154 to 153 million years ago. Characterized by its unique posture with forelimbs longer than its hind limbs, it could reach towering heights to browse on vegetation that other herbivores couldn’t access. With its long neck and small head, the Brachiosaurus is often depicted as one of the most iconic dinosaurs, representing the classic image of a giant, gentle giant roaming ancient forests. Its enormous size, combined with a relatively slow metabolism, likely helped it avoid most predators.",
        "T-Rex" : "The Tyrannosaurus rex, often referred to as T. rex, was one of the largest and most fearsome carnivorous dinosaurs that lived during the Late Cretaceous period, about 68 to 66 million years ago. Standing up to 20 feet tall and stretching over 40 feet in length, T. rex was a powerful predator with a massive skull, filled with large, serrated teeth designed to crush bone and tear flesh. Its strong hind limbs allowed it to move with surprising speed, while its tiny, yet muscular, forearms were likely used to grasp prey. T. rex had keen senses, particularly its vision and sense of smell, which made it an effective hunter and scavenger. As one of the last non-avian dinosaurs before the mass extinction event, T. rex remains one of the most iconic and studied dinosaurs in paleontology.",
        "Stegosaurus" : "The Stegosaurus was a large, herbivorous dinosaur that lived during the Late Jurassic period, about 155 to 150 million years ago. It is easily recognized by the distinctive double row of large, plate-like structures along its back and the spiked tail, known as the thagomizer, which it likely used for defense against predators. Despite its formidable appearance, the Stegosaurus had a small brain relative to its body size, indicating it was not as intelligent as some other dinosaurs.",
        "Triceratops" : "The Triceratops was a large, herbivorous dinosaur that roamed North America during the Late Cretaceous period, about 68 to 66 million years ago. Distinguished by its three prominent facial horns and a large bony frill at the back of its head, the Triceratops is one of the most recognizable dinosaurs. These features likely served as both a defense mechanism against predators like the Tyrannosaurus rex and a display for social interactions within its species. Despite its formidable appearance, the Triceratops was a plant-eater, using its powerful beak to clip vegetation and its strong jaw muscles to chew tough plant material.",
        "Velociraptor" : "The Velociraptor was a small, feathered carnivorous dinosaur that lived during the Late Cretaceous period, approximately 75 to 71 million years ago. Known for its agility and speed, the Velociraptor was a skilled predator, equipped with a distinctive sickle-shaped claw on each foot, which it used to capture and immobilize prey. Although only about the size of a turkey, its intelligence and pack-hunting behavior made it a formidable hunter. Fossil evidence suggests that Velociraptors were likely covered in feathers, linking them closely to modern birds, and they inhabited regions that are now part of Central Asia, particularly Mongolia."
    ]
    
    @State private var environment: EnvironmentResource!
    
    @State private var magnifyingGlass = Entity()

    var body: some View {
        RealityView { content, attachments in
            let dinoWorld = Entity()
            dinoWorld.components.set(WorldComponent())
            
            content.add(dinoWorld)
            // make all entities except the portal a child of this world.
            
            let dinoViewingPortal = createPortal(target: dinoWorld)
            dinoViewingPortal.transform.rotation = simd_quatf(angle: deg2rad(90), axis: [1,0,0])
            // visionos 2.0 only. dinoViewingPortal.components.set(BillboardComponent())
            content.add(dinoViewingPortal)
            
            if let magnifyingGlassScene = try? await Entity(named: "MagnifyingGlassScene", in: realityKitContentBundle) {
                if let magnifyingGlass = magnifyingGlassScene.findEntity(named: "MagnifyingGlass") {
                    self.magnifyingGlass = magnifyingGlass
                    content.add(magnifyingGlass)
                    magnifyingGlass.position = [0, 1, -2]
                    magnifyingGlass.scale *= 2
                }
                
                if let portalAnchor = magnifyingGlass.findEntity(named: "PortalAnchor") {
                    print("adding portal as a child to mag glass")
                    portalAnchor.addChild(dinoViewingPortal)
                }
                
                if let nameLabel = attachments.entity(for: "NameOfDino") {
                    nameLabel.transform.rotation = simd_quatf(angle: deg2rad(-90), axis: [1,0,0])
                    nameLabel.position += [0, 0, -0.19]
                    dinoViewingPortal.addChild(nameLabel)
                }
            }

            guard let environment = try? await EnvironmentResource(named: "PartiallyCloudySkybox") else {
                fatalError("Cannot load environment")
            }
            self.environment = environment
            
            let skybox = await createSkyboxEntity(texture: "skybox2")
            //content.add(skybox)
            //content.add(await loadAllDinos())
            dinoWorld.addChild(skybox)
            dinoWorld.addChild(await loadAllDinos())
            
            if let dinoDescription = attachments.entity(for: "DinoInfo") {
                content.add(dinoDescription)
                dinoDescription.position += [0, 1, -0.5]
            }

        } update: { content, attachments in
            
        } attachments: {
            Attachment(id: "NameOfDino") {
                if(nameOfDino != "") {
                    Text(nameOfDino)
                        .font(.largeTitle)
                        .padding()
                        .glassBackgroundEffect()
                }
                
            }
            
            Attachment(id: "DinoInfo") {
                if(dinoDescription != "") {
                    Text(dinoDescription)
                        .font(.caption)
                        .padding(20)
                        .glassBackgroundEffect()
                        .frame(width: 400)
                }
            }
        }
        .gesture(SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded({ value in
                nameOfDino = value.entity.name
                
                dinoDescription = dinoDescriptions[nameOfDino] ?? ""
        }))
        .gesture(DragGesture().targetedToEntity(magnifyingGlass).onChanged({ value in
            nameOfDino = ""
            magnifyingGlass.position = value.convert(value.location3D, from: .local, to: magnifyingGlass.parent!)
            //fake camera position
            let cameraPos = SIMD3<Float>(0, 1, 0)
            magnifyingGlass.look(at: cameraPos, from: magnifyingGlass.position, upVector: [0,1,0], relativeTo: nil)
            if let portal = magnifyingGlass.findEntity(named: "PortalAnchor") {
                portal.transform.rotation = simd_quatf(angle: deg2rad(180), axis: [0,1,0])
            }
        }))
    }
    
    func loadAllDinos() async -> Entity {
        let allDinos = Entity()
        
        if let brachio = try? await Entity(named: "Brachiosaurus") {
            brachio.name = "Brachiosaurus"
            brachio.position += [15, -2, -10]
            brachio.scale *= 30
            brachio.transform.rotation = simd_quatf(angle: deg2rad(-45), axis: [0,1,0])
            allDinos.addChild(brachio)
            
            brachio.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
            brachio.components.set(ImageBasedLightReceiverComponent(imageBasedLight: brachio))
            
            brachio.components.set(InputTargetComponent())
            brachio.components.set(CollisionComponent(shapes: [.generateBox(width: 15, height: 50, depth: 80).offsetBy(translation: [0,25,0])]))
            brachio.components.set(HoverEffectComponent())

            let anim = brachio.availableAnimations[0]
            brachio.playAnimation(anim.repeat())
        }
        
        if let trex = try? await Entity(named: "Trex") {
            trex.name = "T-Rex"
            trex.position += [-15, 0, -10]
            trex.scale *= 2
            trex.transform.rotation = simd_quatf(angle: deg2rad(45), axis: [0,1,0])
            allDinos.addChild(trex)
            
            trex.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
            trex.components.set(ImageBasedLightReceiverComponent(imageBasedLight: trex))
            
            trex.components.set(InputTargetComponent())
           
            let collision = CollisionComponent(shapes: [.generateBox(width: 400, height: 400, depth: 400).offsetBy(translation: [0,200,0])])
            trex.components.set(collision)
            
            trex.components.set(HoverEffectComponent())

            let anim = trex.availableAnimations[0]
            trex.playAnimation(anim.repeat())
        }
        
        if let stego = try? await Entity(named: "Stegosaurus") {
            stego.name = "Stegosaurus"
            stego.position += [5, 0, -10]
            stego.scale *= 1
            stego.transform.rotation = simd_quatf(angle: deg2rad(25), axis: [0,1,0])
            allDinos.addChild(stego)
            
            stego.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
            stego.components.set(ImageBasedLightReceiverComponent(imageBasedLight: stego))
            
            stego.components.set(InputTargetComponent())
            stego.components.set(CollisionComponent(shapes: [.generateBox(width: 200, height: 200, depth: 200).offsetBy(translation: [0,100,0])]))
            stego.components.set(HoverEffectComponent())

            let anim = stego.availableAnimations[0]
            stego.playAnimation(anim.repeat())
        }
        
        if let triceratops = try? await Entity(named: "Triceratops") {
            triceratops.name = "Triceratops"
            triceratops.position += [0, 0, -10]
            triceratops.scale *= 1
            triceratops.transform.rotation = simd_quatf(angle: deg2rad(10), axis: [0,1,0])
            allDinos.addChild(triceratops)
            
            triceratops.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
            triceratops.components.set(ImageBasedLightReceiverComponent(imageBasedLight: triceratops))
            
            triceratops.components.set(InputTargetComponent())
            triceratops.components.set(CollisionComponent(shapes: [.generateBox(width: 200, height: 200, depth: 200).offsetBy(translation: [0,100,0])]))
            triceratops.components.set(HoverEffectComponent())

            let anim = triceratops.availableAnimations[0]
            triceratops.playAnimation(anim.repeat())
        }
        
        // add velociraptor as an attachment.....
        if let velociraptor = try? await Entity(named: "Velociraptor") {
            velociraptor.name = "Velociraptor"
            velociraptor.position += [-5, 0, -10]
            velociraptor.scale *= 1
            velociraptor.transform.rotation = simd_quatf(angle: deg2rad(-25), axis: [0,1,0])
            allDinos.addChild(velociraptor)
            
            velociraptor.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 2))
            velociraptor.components.set(ImageBasedLightReceiverComponent(imageBasedLight: velociraptor))

            velociraptor.components.set(InputTargetComponent())
            velociraptor.components.set(CollisionComponent(shapes: [.generateBox(width: 200, height: 200, depth: 200).offsetBy(translation: [0,100,0])]))
            velociraptor.components.set(HoverEffectComponent())
            
            let anim = velociraptor.availableAnimations[0]
            velociraptor.playAnimation(anim.repeat())
        }
        
        return allDinos
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
        let portalMesh = MeshResource.generatePlane(width: 0.3, depth: 0.3, cornerRadius: 0.15)// meters
        let portal = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        portal.components.set(PortalComponent(target: target))
        return portal
    }
    
    func deg2rad(_ number: Float) -> Float {
        return number * .pi / 180
    }
}

#Preview {
    FindADinoView()
}
