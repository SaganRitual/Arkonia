import Foundation
import SpriteKit

class NetDisplay {
    let arkon: SKSpriteNode
    let fullNeuronsPortal: SKSpriteNode
    let halfNeuronsPortal: SKSpriteNode
    let layers: [Int]
    var netDisplayGrid: NetDisplayGridProtocol
    let netGraphics: NetGraphics

    init(arkon: SKSpriteNode, fullNeuronsPortal: SKSpriteNode, halfNeuronsPortal: SKSpriteNode, layers: [Int]) {
        Debug.log(level: 159) {
            return "NetDisplay \(NetDisplay.display_counter)"
        }

        self.arkon = arkon
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

    func display() {
        Debug.log(level: 159) {
            NetDisplay.display_counter += 1
            return "Net display.0 \(NetDisplay.display_counter)"
        }

        SceneDispatch.shared.schedule { [unowned self] in // Catch dumb mistakes
            Debug.log(level: 159) {
                return "Net display.1 \(NetDisplay.display_counter)"
            }
            self.display_()
        }
    }

    static var display_counter = 0
    private func display_() {
        Debug.log(level: 159) {
            return "Net display.2 \(NetDisplay.display_counter)"
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
                netGraphics.drawNeuron(for: arkon, at: upperGridPoint, layerRole: layerRole)

                positionsForUpperLayer.append(netDisplayGrid.getPosition(upperGridPoint))
            }
        }
    }
}
