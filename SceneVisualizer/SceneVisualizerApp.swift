//
//  SceneVisualizerApp.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/24/24.
//

import SwiftUI

@main
struct SceneVisualizerApp: App {
    @State private var realityKitModel = RealityKitModel()

    var body: some Scene {
        WindowGroup(id: "main") {
            SettingsView(id: "foo", realityKitModel: self.$realityKitModel)
                .frame(width: 600, height: 780)
        }
        .handlesExternalEvents(matching: [])
        .defaultSize(width: 600, height: 780)
        .windowResizability(.contentSize)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(realityKitModel: self.$realityKitModel)
        }
    }
}
