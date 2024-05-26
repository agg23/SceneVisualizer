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
//            let _ = print($id.wrappedValue)
            SettingsView(id: "foo", realityKitModel: self.$realityKitModel)
        }
        .handlesExternalEvents(matching: [])

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(realityKitModel: self.$realityKitModel)
        }
    }
}
