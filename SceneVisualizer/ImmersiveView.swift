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
    @State private var wristAnchor: AnchorEntity?

    @Binding var realityKitModel: RealityKitModel

    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.entity)

            self.createSettingsAnchor(content: content, attachments: attachments)
        } update: { content, attachments in
            self.wristAnchor?.removeFromParent()

            self.createSettingsAnchor(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "window") {
                WristSettingsTriggerView()
            }
        }
        .task {
            await self.model.start(self.realityKitModel)
        }
        .onAppear {
            self.realityKitModel.arModel = self.model
        }
    }

    func createSettingsAnchor(content: RealityViewContent, attachments: RealityViewAttachments) {
        guard let attachment = attachments.entity(for: "window") else {
            print("Could not find attachment")
            return
        }

        let anchor = AnchorEntity(.hand(self.realityKitModel.settingsOnRight ? .right : .left, location: .wrist), trackingMode: .continuous)
        var transform = Transform()
        // Place window above wrist
        transform.translation.y = 0.1
        anchor.transform = transform

        anchor.addChild(attachment)

        content.add(anchor)
        self.wristAnchor = anchor
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(realityKitModel: .constant(RealityKitModel()))
}
