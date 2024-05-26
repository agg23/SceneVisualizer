//
//  ImmersiveView.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/24/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var model = ARKitModel()

    @Binding var realityKitModel: RealityKitModel

    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.entity)

            guard let attachment = attachments.entity(for: "window") else {
                print("Could not find attachment")
                return
            }

            let anchor = AnchorEntity(.hand(.left, location: .wrist), trackingMode: .continuous)
            var transform = Transform()
            // Place window above wrist
            transform.translation.y = 0.1
            anchor.transform = transform

            anchor.addChild(attachment)

            content.add(anchor)

//            content.add(ModelEntity(mesh: .generateBox(size: 2), materials: [SimpleMaterial(color: .blue, isMetallic: false)]))
        } update: { content, attachments in

        } attachments: {
            Attachment(id: "window") {
                WristSettingsTriggerView()
            }
        }
        .task {
            await self.model.start()
        }
        .onAppear {
            self.realityKitModel.arModel = model
        }
//        .onAppear {
//            self.dismissWindow(id: "main")
//        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(realityKitModel: .constant(RealityKitModel()))
}
