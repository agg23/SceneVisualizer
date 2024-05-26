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

    var ripple = false {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)
        }
    }

    var wireframe = true {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)
        }
    }

    var meshColor = Color.red {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)
        }
    }
    var enableMeshColor = false {
        didSet {
            self.arModel?.updateProximityMaterialProperties(self)
        }
    }
}
