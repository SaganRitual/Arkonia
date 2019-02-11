import Foundation
import SpriteKit

struct DSpacer {
    var cNeurons: Int!
    var hLeft = CGFloat(0.0)
    var hSpacing = CGFloat(0.0)
    var layerRole = DLayer.LayerRole.senseLayer
    let portal: SKNode
    let height: CGFloat
    let width: CGFloat
    var vSpacing = CGFloat(0.0)
    var vTop = CGFloat(0.0)

    init(portal: SKNode, cLayers: Int) {
        self.portal = portal
        self.height = portal.frame.height
        self.width = portal.frame.width

        self.setVerticalSpacing(cLayers: cLayers)
    }

    func getPosition(for dNeuron: DNeuron) -> CGPoint {
        let xSS = dNeuron.neuron.id.myID
        let ySS = dNeuron.neuron.id.parentID    // The layer
        return getPosition(DGridPosition(x: xSS, y: ySS))
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

    mutating func setHorizontalSpacing(cNeurons: Int) {
        self.hLeft = -width / 2.0
        self.hSpacing = width / CGFloat(cNeurons + 1)
    }

    mutating func setLayerRole(_ layerRole: DLayer.LayerRole) {
        self.layerRole = layerRole
    }

    mutating func setVerticalSpacing(cLayers: Int) {
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
