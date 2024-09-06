//
//  DinopediaApp.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/24/24.
//

import SwiftUI

@main
struct DinopediaApp: App {
    
    public static let homeView = "homeView"
    public static let dinoCard = "dinoCard"
    public static let dinoPortalCard = "dinoPortalCard"
    public static let triceratopsVolume = "triceratopsVolume"
    public static let velociraptorVolume = "velociraptorVolume"
    public static let stegosaurusModel3D = "stegosaurusModel3D"
    public static let stegosaurusRealityView = "stegosaurusRealityView"
    public static let brachiosaurusImmersive = "brachiosaurusImmersive"
    public static let findADino = "findADino"
    
    var body: some Scene {
        WindowGroup(id: Self.homeView) {
            HomeView()
        }
        .defaultSize(width: 1200, height: 1000)
        
        WindowGroup(id: Self.dinoCard) {
            DinoCardView()
        }
        .defaultSize(width: 600, height: 650)
        
        WindowGroup(id: Self.dinoPortalCard) {
            DinoPortalCard()
        }
        .defaultSize(width: 600, height: 650)
        
        WindowGroup(id: Self.triceratopsVolume) {
            TriceratopsVolumeView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 2, depth: 2, in: .meters)
        
        WindowGroup(id: Self.velociraptorVolume) {
            VelociraptorVolumeView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 1, depth: 2, in: .meters)

        ImmersiveSpace(id: Self.stegosaurusModel3D) {
            ImmersiveStegosaurusView()
        }
        
        ImmersiveSpace(id: Self.stegosaurusRealityView) {
            ImmersiveAnimatedStegosaurusView()
        }
        
        ImmersiveSpace(id: Self.brachiosaurusImmersive) {
            ImmersiveBrachiosaurusView()
        }

        ImmersiveSpace(id: Self.findADino) {
            FindADinoView()
        }
        
    }
}
