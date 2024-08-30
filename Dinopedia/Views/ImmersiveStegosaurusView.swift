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
                .scaleEffect(manipulationState.transform.scale.width)
                .rotation3DEffect(.degrees(90), axis: .y)
                .rotation3DEffect(manipulationState.transform.rotation ?? .identity)
                .offset(x: manipulationState.transform.translation.x, y: manipulationState.transform.translation.y)
                .offset(z:  manipulationState.transform.translation.z)
                .offset(y: yOffsetOfDino) // -1500 talk about the pain here of using point value
                .offset(z: zOffsetOfDino) // -5000
            
                .overlay(alignment: .topLeading) {
                    VStack {
                        Text("The Stegosaurus was a large, herbivorous dinosaur that lived during the Late Jurassic period, about 155 to 150 million years ago. It is easily recognized by the distinctive double row of large, plate-like structures along its back and the spiked tail, known as the thagomizer, which it likely used for defense against predators. Despite its formidable appearance, the Stegosaurus had a small brain relative to its body size, indicating it was not as intelligent as some other dinosaurs.")
                            .font(.largeTitle)
                            .frame(width: 700)
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
        .gesture(manipulationGesture.updating($manipulationState) { value, state, _ in
            state.active = true
            state.transform = value
        })
        .onAppear {
            dismissWindow(id: "HomeView")
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

