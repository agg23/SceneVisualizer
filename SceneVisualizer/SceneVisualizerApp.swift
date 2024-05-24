//
//  SceneVisualizerApp.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/24/24.
//

import SwiftUI

@main
struct SceneVisualizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
