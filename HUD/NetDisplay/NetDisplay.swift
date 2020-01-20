import Foundation
import SpriteKit

class NetDisplay {
    let background: SKSpriteNode
    let layers: [Int]
    var netDisplayGrid: NetDisplayGridProtocol
    let netGraphics: NetGraphics
    let spriteFactory: SpriteFactory

    init(scene: SKScene, background: SKSpriteNode, layers: [Int]) {
        self.spriteFactory = SpriteFactory(
            scene: scene,
            thoraxFactory: SpriteFactory.makeFakeThorax(texture:),
            noseFactory: SpriteFactory.makeFakeNose(texture:)
        )

        self.background = background
        self.layers = layers

        self.netDisplayGrid = NetDisplayGrid(portal: background, cHiddenLayers: layers.count - 2)
        self.netGraphics = NetGraphics(
            background: background,
            fullNeuronsHangar: spriteFactory.fullNeuronsHangar,
            halfNeuronsHangar: spriteFactory.halfNeuronsHangar,
            linesHangar: spriteFactory.linesHangar,
            netDisplayGrid: netDisplayGrid
        )
    }

    func display() {
        SceneDispatch.schedule {self.display_() }
    }

    private func display_() {
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

    func reset() {
        Debug.log("~NetDisplay", level: 20)
        SceneDispatch.schedule {
            /* strong self in */ self.background.removeAllChildren()
        }
    }
}
