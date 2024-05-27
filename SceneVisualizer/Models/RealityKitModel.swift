//
//  RealityKitModel.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/25/24.
//

import SwiftUI

@Observable class RealityKitModel {
    weak var arModel: ARKitModel?

    var immersiveSpaceIsShown = false

    var ripple: Bool {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)

            UserDefaults.standard.setValue(self.ripple, forKey: "ripple")
        }
    }

    var wireframe = true {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)

            UserDefaults.standard.setValue(self.wireframe, forKey: "wireframe")
        }
    }

    var meshColor: Color {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)

            UserDefaults.standard.setValue(self.meshColor.rawValue, forKey: "meshColor")
        }
    }
    var enableMeshColor: Bool {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)

            UserDefaults.standard.setValue(self.enableMeshColor, forKey: "enableMeshColor")
        }
    }

    var settingsOnRight: Bool {
        didSet {
            UserDefaults.standard.setValue(self.settingsOnRight, forKey: "settingsOnRight")
        }
    }

    init() {
        self.ripple = UserDefaults.standard.bool(forKey: "ripple")

        self.wireframe = UserDefaults.standard.value(forKey: "wireframe") as? Bool ?? true

        self.meshColor = if let colorString = UserDefaults.standard.string(forKey: "meshColor"), let color = Color(rawValue: colorString) {
            color
        } else {
            .red
        }
        self.enableMeshColor = UserDefaults.standard.value(forKey: "enableMeshColor") as? Bool ?? false

        self.settingsOnRight = UserDefaults.standard.value(forKey: "settingsOnRight") as? Bool ?? false
    }
}
