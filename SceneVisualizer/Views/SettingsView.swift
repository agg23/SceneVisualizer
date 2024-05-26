//
//  SettingsView.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/25/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismiss) private var dismiss

    let id: String?

    @Binding var realityKitModel: RealityKitModel

    var body: some View {
        let showSpace = Binding {
            self.$realityKitModel.wrappedValue.immersiveSpaceIsShown
        } set: { newValue in
            self.changeImmersiveState(newValue)
        }

        VStack {
            Toggle("Ripple", isOn: Binding(get: { self.realityKitModel.ripple }, set: { value in
                self.realityKitModel.ripple = value
            }))

            Toggle("Display Wireframe", isOn: Binding(get: { self.realityKitModel.wireframe }, set: { value in
                self.realityKitModel.wireframe = value
            }))

            Toggle("Use Custom Color", isOn: Binding(get: { self.realityKitModel.enableMeshColor }, set: { value in
                self.realityKitModel.enableMeshColor = value
            }))

            ColorPicker(selection: Binding(get: { self.realityKitModel.meshColor }, set: { value in
                self.realityKitModel.meshColor = value
            }), label: {
                Text("Custom Color")
            })

            Toggle("Show Space", isOn: showSpace)
        }
        .padding()
    }

    func changeImmersiveState(_ state: Bool) {
        Task {
            if state {
                switch await self.openImmersiveSpace(id: "ImmersiveSpace") {
                case .opened:
                    self.realityKitModel.immersiveSpaceIsShown = true
                case .error, .userCancelled:
                    fallthrough
                @unknown default:
                    self.realityKitModel.immersiveSpaceIsShown = false
                }
            } else if self.realityKitModel.immersiveSpaceIsShown {
                await self.dismissImmersiveSpace()
                self.realityKitModel.immersiveSpaceIsShown = false
            }
        }
    }
}

#Preview {
    SettingsView(id: "main", realityKitModel: .constant(RealityKitModel()))
}
