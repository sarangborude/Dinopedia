//
//  HeadsetPositionManager.swift
//  Dinopedia
//
//  Created by Sarang Borude on 9/10/24.
//
// I am writing all this code for vision os compatibility for find a dino
// please just use billboard component on VisionOS 2.0

import ARKit
import RealityKit
import OSLog
import GameController

let logger = Logger(subsystem: "Sarang-Borude.Dinopedia", category: "general")

@Observable
@MainActor
class HeadsetPositionManager {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    public var deviceLocation = Entity()
    
    var errorState = false
    
    var dataProvidersAreSupported: Bool {
        WorldTrackingProvider.isSupported
    }
    
    var isReadyToRun: Bool {
        worldTracking.state == .initialized
    }
    
    func processDeviceAnchorUpdates() async {
        await run(function: self.queryAndProcessLatestDeviceAnchor, withFrequency: 90)
        print("Starting to process device anchor updates")
    }
    
    func run(function: () async -> Void, withFrequency hz: UInt64) async {
        while true {
            if Task.isCancelled {
                return
            }
            
            // Sleep for 1 s / hz before calling the function.
            let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
            do {
                try await Task.sleep(nanoseconds: nanoSecondsToSleep)
            } catch {
                // Sleep fails when the Task is cancelled. Exit the loop.
                return
            }
            
            await function()
        }
    }
    
    private func queryAndProcessLatestDeviceAnchor() async {
        // Device anchors are only available when the provider is running.
        guard worldTracking.state == .running else { return }
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        
        guard let deviceAnchor, deviceAnchor.isTracked else { return }
        
        self.deviceLocation.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
    }
    
    /// Responds to events like authorization revocation.
    func monitorSessionEvents() async {
        for await event in session.events {
            switch event {
            case .authorizationChanged(type: _, status: let status):
                logger.info("Authorization changed to: \(status)")
                
                if status == .denied {
                    errorState = true
                }
            case .dataProviderStateChanged(dataProviders: let providers, newState: let state, error: let error):
                logger.info("Data provider changed: \(providers), \(state)")
                if let error {
                    logger.error("Data provider reached an error state: \(error)")
                    errorState = true
                }
            @unknown default:
                fatalError("Unhandled new event type \(event)")
            }
        }
    }
    
}
