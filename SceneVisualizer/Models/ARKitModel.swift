//
//  ARKitModel.swift
//  SceneVisualizer
//
//  Created by Adam Gastineau on 5/24/24.
//

import RealityKit
import ARKit

@Observable final class ARKitModel {
    private let arSession = ARKitSession()
    private let sceneReconstructionProvider = SceneReconstructionProvider(modes: [.classification])

    let entity = Entity()

    private var activeShaderMaterial: Material?
    private var meshEntities: [UUID: OccludedEntityPair] = [:]

    private var material: Material {
        get {
            if var material = self.activeShaderMaterial as? ShaderGraphMaterial {
                // Enable displaying wireframe
                material.triangleFillMode = .lines

                return material
            } else {
                var material = SimpleMaterial(color: .red.withAlphaComponent(0.7), isMetallic: false)
                material.triangleFillMode = .lines

                return material
            }
        }
    }

    func start() async {
        guard SceneReconstructionProvider.isSupported else {
            print("SceneReconstructionProvider not supported.")
            return
        }

        do {
            self.activeShaderMaterial = try await ShaderGraphMaterial(named: "/Root/ProximityMaterial", from: "Materials")
        } catch {
            print(error)
        }

        do {
            try await self.arSession.run([self.sceneReconstructionProvider])
            print("Started ARKit")

            for await update in self.sceneReconstructionProvider.anchorUpdates {
                if Task.isCancelled {
                    print("Quit ARKit task")
                    return
                }

                print("Anchor update: \(update)")
                await processMeshAnchorUpdate(update)
            }
        } catch {
            print("ARKit error \(error)")
        }
    }

    @MainActor
    func processMeshAnchorUpdate(_ update: AnchorUpdate<MeshAnchor>) async {
        let meshAnchor = update.anchor

        // Used for collision only, so not used here
//        guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else { return }

        let transform = Transform(matrix: meshAnchor.originFromAnchorTransform)

        switch update.event {
        case .added:
            let primaryMesh = try! generateMesh(from: meshAnchor.geometry)
            let occlusionMesh = try! generateMesh(from: meshAnchor.geometry, with: { vertex, normal in -0.01 * normal + vertex } )

            let primaryEntity = ModelEntity(mesh: primaryMesh, materials: [self.material])
            // SimpleMaterial is provided as for some reason the occlusion doesn't work without it
            let occlusionEntity = ModelEntity(mesh: occlusionMesh, materials: [OcclusionMaterial(), SimpleMaterial(color: .blue, isMetallic: false)])

            primaryEntity.transform = transform

            // Interaction and collision
//            primaryEntity.collision = CollisionComponent(shapes: [shape], isStatic: true)
//            primaryEntity.components.set(InputTargetComponent())
//            primaryEntity.physicsBody = PhysicsBodyComponent(mode: .static)

            occlusionEntity.transform = transform

            self.meshEntities[meshAnchor.id] = OccludedEntityPair(primaryEntity: primaryEntity, occlusionEntity: occlusionEntity)
            self.entity.addChild(primaryEntity)
            self.entity.addChild(occlusionEntity)

        case .updated:
            guard let pair = self.meshEntities[meshAnchor.id] else {
                return
            }

            pair.primaryEntity.transform = transform
            pair.occlusionEntity.transform = transform

            // Collision
//            pair.primaryEntity.collision?.shapes = [shape]

        case .removed:
            if let pair = self.meshEntities[meshAnchor.id] {
                pair.primaryEntity.removeFromParent()
                pair.occlusionEntity.removeFromParent()
            }

            self.meshEntities.removeValue(forKey: meshAnchor.id)
        }
    }

    // Data extraction derived from https://github.com/XRealityZone/what-vision-os-can-do/blob/3a731b5645f1c509689637e66ee96693b2fa2da7/WhatVisionOSCanDo/ShowCase/WorldScening/WorldSceningTrackingModel.swift
    @MainActor func generateMesh(from geometry: MeshAnchor.Geometry, with vertexTransform: ((_ vertex: SIMD3<Float>, _ normal: SIMD3<Float>) -> SIMD3<Float>)? = nil) throws -> MeshResource {
        var desc = MeshDescriptor()
        let vertices = geometry.vertices.asSIMD3(ofType: Float.self)
        let normalValues = geometry.normals.asSIMD3(ofType: Float.self)

        let modifiedVertices = if let vertexTransform = vertexTransform {
            zip(vertices, normalValues).map { vertex, normal in
                vertexTransform(vertex, normal)
            }
        } else {
            vertices
        }

        desc.positions = .init(modifiedVertices)
        desc.normals = .init(normalValues)
        desc.primitives = .polygons(
            (0..<geometry.faces.count).map { _ in UInt8(3) },
            (0..<geometry.faces.count * 3).map {
                geometry.faces.buffer.contents()
                    .advanced(by: $0 * geometry.faces.bytesPerIndex)
                    .assumingMemoryBound(to: UInt32.self).pointee
            }
        )

        return try MeshResource.generate(from: [desc])
    }
}

private struct OccludedEntityPair {
    let primaryEntity: ModelEntity
    let occlusionEntity: ModelEntity
}
