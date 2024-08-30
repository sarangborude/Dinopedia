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
        VStack {
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
                .frame(width: 200, height: 200)
                .frame(depth: 200)
                .overlay(alignment: .bottom) {
                    Button(action: {
                        openWindow(id: DinopediaApp.velociraptorVolume)
                    }, label: {
                        Text("Show Model")
                    })

                }
           
            Text("The Velociraptor was a small, fast, and intelligent dinosaur known for its sharp claws and hunting prowess during the Late Cretaceous period.")
                .frame(maxWidth: 300)
                .padding(40)
        }
        //.glassBackgroundEffect()
    }
}

#Preview {
    DinoCardView()
}
