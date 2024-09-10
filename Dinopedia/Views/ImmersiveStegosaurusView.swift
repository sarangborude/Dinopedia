//
//  ImmersiveStegosaurusView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/25/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveStegosaurusView: View {
    
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    @PhysicalMetric(from: .meters) private var zOffsetOfDino = -3
    @PhysicalMetric(from: .meters) private var yOffsetOfDino =  -1
    
    @PhysicalMetric(from: .meters) private var xOffsetOfCard =  0.5
    @PhysicalMetric(from: .meters) private var zOffsetOfCard = -2
    @PhysicalMetric(from: .meters) private var yOffsetOfCard =  -0.4
    
    var manipulationGesture: some Gesture<AffineTransform3D> {
        DragGesture()
            .simultaneously(with: MagnifyGesture())
            .simultaneously(with: RotateGesture3D())
            .map { gesture in
                let (translation, scale, rotation) = gesture.components()
                return AffineTransform3D(
                    scale: scale,
                    rotation: rotation,
                    translation: translation)
            }
    }
    
    @State private var scale: Double = 1
    @State private var initialScale: Double = 1
    @State private var rotation: Rotation3D = .identity
    @State private var initialRotation: Rotation3D = .identity
    @State private var translation: Vector3D = .zero
    @State private var initialTranslation: Vector3D = .zero
    
    @State private var isGestureStarted = false
    
    struct ManipulationState {
        var transform: AffineTransform3D = .identity
        var active: Bool = false
    }
    
    @GestureState private var manipulationState = ManipulationState()
    
    var body: some View {
        
        Model3D(named: "Stegosaurus", bundle: realityKitContentBundle) { model in
            model
                .resizable()
                .scaledToFit()
            
            // Order of manipulations below matter always Scale first, then rotate, then translate
            
            // Scaling
                .scaleEffect(manipulationState.transform.scale.width)
            // Uncomment the line below after commenting the above manipulations if you want your manipulation to not revert after manipulation ends
                //.scaleEffect(scale)
            
            // Rotation
            // Initial rotation
                .rotation3DEffect(.degrees(90), axis: .y)
            
                .rotation3DEffect(manipulationState.transform.rotation ?? .identity)
            // Uncomment the line below after commenting the above manipulations if you want your manipulation to not revert after manipulation ends
                //.rotation3DEffect(rotation)
            
            // Translation
            // Initial offset
                .offset(y: yOffsetOfDino) // -1500 talk about the pain here of using point value
                .offset(z: zOffsetOfDino) // -5000
            
            // Uncomment the line below after commenting the above manipulations if you want your manipulation to not revert after manipulation ends
                .offset(x: manipulationState.transform.translation.x, y: manipulationState.transform.translation.y)
                .offset(z: manipulationState.transform.translation.z)
                //.offset(x: translation.x, y: translation.y)
                //.offset(z: translation.z)
             
                .overlay(alignment: .topLeading) {
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
                    .offset(z: zOffsetOfCard)
                    .offset(x: xOffsetOfCard, y: yOffsetOfCard)
                }
        } placeholder: {
            ProgressView()
        }
        .animation(.easeInOut, value: manipulationState.transform)
        
        //Only uncomment one set of gesture(s) below
        
        //******** Using the updating closure along with manipulation state reverts the manipulations to initial position after gesture ends *****
        
        .gesture(manipulationGesture.updating($manipulationState, body: { value, state, _ in
            state.active = true
            state.transform = value
        }))
        
        // Uncomment the gestures below after commenting the one above.
        // Use drag gesture separately along with simulataneous rotate and scale. this works the best if you want to keep your manipulations
        // You can use the combine simultaneous gesture from above but it will give your rotation issues when you try to manipulate the entire transform in one go
        
//        .gesture(DragGesture().targetedToAnyEntity()
//            .onChanged({ value in
//                if(!isGestureStarted) {
//                    isGestureStarted = true
//                    initialTranslation = translation
//                }
//                translation = initialTranslation + value.translation3D
//            })
//                .onEnded({ value in
//                    isGestureStarted = false
//                })
//        )
//        .gesture(RotateGesture3D().simultaneously(with: MagnifyGesture()).targetedToAnyEntity()
//            .onChanged({ value in
//                if(!isGestureStarted) {
//                    isGestureStarted = true
//                    initialRotation = rotation
//                    initialScale = scale
//                }
//                rotation = initialRotation * (value.first?.rotation ?? .identity)
//                scale = initialScale * (value.second?.magnification ?? 1)
//            })
//                .onEnded({ value in
//                    isGestureStarted = false
//                }))
        
        
        .onAppear {
            dismissWindow(id: DinopediaApp.homeView)
        }
        .onDisappear {
            openWindow(id: DinopediaApp.homeView)
        }
    }
}

#Preview {
    ImmersiveStegosaurusView()
}

// Helper for extracting translation, magnification, and rotation.
extension SimultaneousGesture<
    SimultaneousGesture<DragGesture, MagnifyGesture>,
    RotateGesture3D>.Value {
        func components() -> (Vector3D, Size3D, Rotation3D) {
            let translation = self.first?.first?.translation3D ?? .zero
            let magnification = self.first?.second?.magnification ?? 1
            let size = Size3D(width: magnification, height: magnification, depth: magnification)
            let rotation = self.second?.rotation ?? .identity
            return (translation, size, rotation)
        }
    }

