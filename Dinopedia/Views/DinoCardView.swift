//
//  DinoCardView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/24/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct DinoCardView: View {
    
    @Environment(\.openWindow) private var openWindow
        
    var body: some View {
        VStack(spacing: 50) {
            
            Text("Velociraptor")
                .font(.extraLargeTitle2)
                .padding(40)
            
                Model3D(named: "Velociraptor", bundle: realityKitContentBundle) { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .rotation3DEffect(.degrees(90 ) , axis: .y)
                } placeholder: {
                    ProgressView()
                }
                .frame(depth: 200, alignment: .center)
                .frame(height: 200)
                .overlay(alignment: .bottom) {
                    Button(action: {
                        openWindow(id: DinopediaApp.velociraptorVolume)
                    }, label: {
                        Text("Show Model")
                    })
                    .frame(width: 200)
                }
           
            Text("The Velociraptor was a small, fast, and intelligent dinosaur known for its sharp claws and hunting prowess during the Late Cretaceous period.")
                .frame(maxWidth: 500)
                .padding(40)
        }
        //.glassBackgroundEffect()
    }
}

#Preview {
    DinoCardView()
}
