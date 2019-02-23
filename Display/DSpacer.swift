import Foundation
import SpriteKit

class DSpacer {
    var cNeurons: Int!
    let height: CGFloat
    var hLeft = CGFloat(0.0)
    var hSpacing = CGFloat(0.0)
    var layerRole = DLayer.LayerRole.senseLayer
    var neuronPositions: [KIdentifier: CGPoint]
    let portal: SKSpriteNode
    var vSpacing = CGFloat(0.0)
    var vTop = CGFloat(0.0)
    let width: CGFloat

    init(portal: SKSpriteNode, cLayers: Int) {
        self.portal = portal
        self.height = portal.frame.height
        self.width = portal.frame.width
        self.neuronPositions = [:]
        self.setVerticalSpacing(cLayers: cLayers)
    }

    func getPosition(for id: KIdentifier) -> CGPoint {
        return neuronPositions[id]!
    }

    func getPosition(_ gridPosition: DGridPosition) -> CGPoint {
        let yOffset: CGFloat = {
            switch self.layerRole {
            case .motorLayer:  return height
            case .hiddenLayer: return CGFloat(gridPosition.y + 1) * vSpacing
            case .senseLayer:  return 0
            }
        }()

        let x = getX(gridPosition.x)
        let y = vTop - yOffset
        return CGPoint(x: x, y: y)
    }

    private func getX(_ xSS: Int) -> CGFloat {
        return hLeft + CGFloat(xSS + 1) * hSpacing
    }

    func setHorizontalSpacing(cNeurons: Int) {
        self.hLeft = -width / 2.0
        self.hSpacing = width / CGFloat(cNeurons + 1)
    }

    func setLayerRole(_ layerRole: DLayer.LayerRole) {
        self.layerRole = layerRole
    }

    func setPosition(id: KIdentifier, gridX: Int, gridY: Int) {
        let position = getPosition(DGridPosition(x: gridX, y: gridY))
        guard let p = neuronPositions[id] else { neuronPositions[id] = position; return }
        precondition(p == position, "neuronPositions[\(id)] = \(p) already; now setting to \(position)?")
    }

    func setVerticalSpacing(cLayers: Int) {
        self.vSpacing = height / CGFloat(cLayers + 1)
        self.vTop = height / 2.0
    }
}

extension DSpacer {
    struct DGridPosition {
        var x: Int
        var y: Int

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
}
