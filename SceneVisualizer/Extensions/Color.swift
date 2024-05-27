//
//  Color.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/27/24.
//

import SwiftUI

extension Color: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue),
              let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return nil
        }
        self = Color(color)
    }

    public var rawValue: String {
        let data = try? NSKeyedArchiver.archivedData(
            withRootObject: UIColor(self), requiringSecureCoding: false)
        return data?.base64EncodedString() ?? ""
    }
}
