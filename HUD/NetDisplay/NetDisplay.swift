import Foundation
import SpriteKit

class NetDisplay {
    let fullNeuronsPortal: SKSpriteNode
    let halfNeuronsPortal: SKSpriteNode
    let layers: [Int]
    var netDisplayGrid: NetDisplayGridProtocol
    let netGraphics: NetGraphics

    init(fullNeuronsPortal: SKSpriteNode, halfNeuronsPortal: SKSpriteNode, layers: [Int]) {
        self.fullNeuronsPortal = fullNeuronsPortal
        self.halfNeuronsPortal = halfNeuronsPortal
        self.layers = layers

        self.netDisplayGrid = NetDisplayGrid(portal: fullNeuronsPortal, cHiddenLayers: layers.count - 2)

        self.netGraphics = NetGraphics(
            fullNeuronsPortal: fullNeuronsPortal,
            halfNeuronsPortal: halfNeuronsPortal,
            netDisplayGrid: netDisplayGrid
        )
    }

    deinit {
        SpriteFactory.shared.fullNeuronsPool.releaseSprites(from: fullNeuronsPortal)
        SpriteFactory.shared.halfNeuronsPool.releaseSprites(from: halfNeuronsPortal)
    }

    func display() {
        SceneDispatch.schedule {
            Debug.log(level: 102) { "net display" }
            self.display_()
        }
    }

    static var display_counter = 0
    private func display_() {
        Debug.log(level: 100) {
            NetDisplay.display_counter += 1
            return "Net display \(NetDisplay.display_counter)"
        }

        let neuronRadius = CGFloat(25)

        let cHiddenLayers = layers.count - 2
        let includeMotorLayer = cHiddenLayers + 1

        var positionsForUpperLayer = [CGPoint]()

        (-1..<includeMotorLayer).forEach { layerSS in
            let cNeurons = layers[layerSS + 1]

            netDisplayGrid.setHorizontalSpacing(cNeurons: cNeurons, padRadius: neuronRadius)

            let layerRole: LayerRole = {
                switch layerSS {
                case -1: return .senseLayer
                case includeMotorLayer - 1: return .motorLayer
                default: return .hiddenLayer
                }
            }()

            netDisplayGrid.layerRole = layerRole

            positionsForUpperLayer.removeAll(keepingCapacity: true)

            (0..<cNeurons).forEach { neuronSS in
                let upperGridPoint = GridPoint(x: neuronSS, y: layerSS)
                netGraphics.drawNeuron(at: upperGridPoint, layerRole: layerRole)

                positionsForUpperLayer.append(netDisplayGrid.getPosition(upperGridPoint))
            }
        }
    }
}
