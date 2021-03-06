import Foundation
import SpriteKit

class NetDisplayGrid: NetDisplayGridProtocol {

    var cNeurons: Int!
    let height: CGFloat
    var hLeft = CGFloat(0.0)
    var hSpacing = CGFloat(0.0)
    var layerRole = LayerRole.senseLayer
    var neuronPositions = [KIdentifier: CGPoint]()
    let portal: SKSpriteNode
    var vSpacing = CGFloat(0.0)
    var vTop = CGFloat(0.0)
    let width: CGFloat

    init(portal: SKSpriteNode, cHiddenLayers: Int) {
        self.portal = portal
        self.height = portal.size.height
        self.width = portal.size.width
        self.setVerticalSpacing(cHiddenLayers: cHiddenLayers)
    }

    func getPosition(_ gridPosition: GridPoint) -> CGPoint {
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

    func setHorizontalSpacing(cNeurons: Int, padRadius: CGFloat = 0) {
        self.hSpacing = (width - padRadius * 2.0) / CGFloat(cNeurons)
        self.hLeft = padRadius - (width + hSpacing) / 2.0
    }

    func setPosition(id: KIdentifier, gridX: Int, gridY: Int) {
        let position = getPosition(GridPoint(x: gridX, y: gridY))
        guard let p = neuronPositions[id] else { neuronPositions[id] = position; return }
        hardAssert(p == position) {
            "neuronPositions[\(id)] = \(p) already; now setting to \(position)?"
        }
    }

    func setVerticalSpacing(cHiddenLayers: Int) {
        self.vSpacing = height / CGFloat(cHiddenLayers + 1)
        self.vTop = height / 2.0
    }
}
