//
//  HomeView.swift
//  Dinopedia
//
//  Created by Sarang Borude on 8/27/24.
//

import SwiftUI

@MainActor
struct HomeView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        VStack {
            Text("Welcome to Dinopedia")
                .font(.extraLargeTitle)
            
            VStack(alignment: .center, spacing: 20) {
                
                HStack(spacing: 20) {
                    Button(action: {
                        openWindow(id: DinopediaApp.dinoCard)
                    }, label: {
                        VStack(spacing: 10) {
                            Image("Velociraptor")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 150, height: 150)
                            Text("Velociraptor Card")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                    .gridColumnAlignment(.listRowSeparatorTrailing)
                    
                    Button(action: {
                        openWindow(id: DinopediaApp.dinoPortalCard)
                    }, label: {
                        VStack(spacing: 10) {
                            Image("Triceratops")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 150, height: 150)
                            Text("Triceratops Portal Card")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                }
                .frame(height: 220)
                
                HStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await openSpace(id: DinopediaApp.stegosaurusModel3D)
                        }
                    }, label: {
                        VStack(spacing: 10) {
                            Image("Stegosaurus")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 150, height: 150)
                            Text("Stegosaurus Model3D")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                    
                    Button(action: {
                        Task {
                            await openSpace(id: DinopediaApp.stegosaurusRealityView)
                        }
                    }, label: {
                        VStack(spacing: 10) {
                            Image("Stegosaurus")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 150, height: 150)
                            Text("Stegosaurus RealityView")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                    
                    Button(action: {
                        Task {
                            await openSpace(id: DinopediaApp.brachiosaurusImmersive)
                        }
                    }, label: {
                        VStack(spacing: 10) {
                            Image("Brachiosaurus")
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(width: 150, height: 150)
                            Text("Brachiosaurus Immersive")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                }
                .frame(height: 220)
                
                HStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await openSpace(id: DinopediaApp.findADino)
                        }
                    }, label: {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 150, height: 150)
                            Text("Find A Dino")
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: 25))
                }
                .frame(height: 220)
            }
            .padding()
        }
        .padding(100)
    }
    
    func openSpace(id: String) async {
        
        //dismiss any open immersive space first
        await dismissImmersiveSpace()
        
        switch await openImmersiveSpace(id: id) {
        case .opened:
            print("Immersive space \(id) successfully opened")
        case .error:
            fatalError("Error opening immersive space with id: \(id)")
        case .userCancelled:
            print("User cancelled")
        default:
            break
        }
    }
}

#Preview {
    HomeView()
}
