//
//  ImmersiveView.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/24/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State var model = ARKitModel()

    var body: some View {
        RealityView { content in
            content.add(self.model.entity)
        }
        .task {
            await self.model.start()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
