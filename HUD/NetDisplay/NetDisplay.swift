import Foundation
import SpriteKit

class NetDisplay {
    let arkon: SKSpriteNode
    let fullNeuronsPortal: SKSpriteNode
    let halfNeuronsPortal: SKSpriteNode
    let layerDescriptors: [Int]
    var netDisplayGrid: NetDisplayGridProtocol
    let netGraphics: NetGraphics

    init(
        arkon: SKSpriteNode, fullNeuronsPortal: SKSpriteNode,
        halfNeuronsPortal: SKSpriteNode, layerDescriptors: [Int]
    ) {
        Debug.log(level: 159) {
            return "NetDisplay \(NetDisplay.display_counter)"
        }

        self.arkon = arkon
        self.fullNeuronsPortal = fullNeuronsPortal
        self.halfNeuronsPortal = halfNeuronsPortal
        self.layerDescriptors = layerDescriptors

        self.netDisplayGrid = NetDisplayGrid(portal: fullNeuronsPortal, cHiddenLayers: layerDescriptors.count - 2)

        self.netGraphics = NetGraphics(
            fullNeuronsPortal: fullNeuronsPortal,
            halfNeuronsPortal: halfNeuronsPortal,
            netDisplayGrid: netDisplayGrid
        )
    }

    deinit {
        Debug.log(level: 205) { "~NetDisplay" }
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

    // swiftlint:disable function_body_length
    // Function Body Length Violation: Function body should span 40 lines or
    // less excluding comments and whitespace: currently spans 41 lines (function_body_length)
    static var display_counter = 0
    private func display_() {
        Debug.log(level: 159) {
            return "Net display.2 \(NetDisplay.display_counter)"
        }

        let neuronRadius = CGFloat(25)

        let cHiddenLayers = layerDescriptors.count - 2
        let includeMotorLayer = cHiddenLayers + 1

        var positionsForUpperLayer = [CGPoint]()
        var layerSS = -1
        var cNeurons = 0
        var nextNeuronSS = 0
        var layerRole = LayerRole.senseLayer

        func a() {
            if layerSS < includeMotorLayer { b() }
        }

        func b() {
            nextNeuronSS = 0
            cNeurons = layerDescriptors[layerSS + 1]

            Debug.log(level: 189) {
                "display_.b0 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons)"
            }

            netDisplayGrid.setHorizontalSpacing(cNeurons: cNeurons, padRadius: neuronRadius)

            layerRole = {
                switch layerSS {
                case -1: return .senseLayer
                case includeMotorLayer - 1: return .motorLayer
                default: return .hiddenLayer
                }
            }()

            netDisplayGrid.layerRole = layerRole

            positionsForUpperLayer.removeAll(keepingCapacity: true)

            Debug.log(level: 189) {
                "display_.b1 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons)"
            }

            c()

            Debug.log(level: 189) {
                "display_.b2 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons)"
            }
        }

        func c() {
            Debug.log(level: 189) {
                "display_.c0 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons)"
            }

            guard cNeurons > 0 else {
                layerSS += 1
                SceneDispatch.shared.schedule(a)
                return
            }

            let cNeurons_ = min(cNeurons, 30)
            Debug.log(level: 189) {
                "display_.c1 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons_)"
            }

            (0..<cNeurons_).forEach {
                let neuronSS = nextNeuronSS + $0
                let upperGridPoint = GridPoint(x: neuronSS, y: layerSS)
                netGraphics.drawNeuron(for: arkon, at: upperGridPoint, layerRole: layerRole)

                positionsForUpperLayer.append(netDisplayGrid.getPosition(upperGridPoint))
            }

            cNeurons -= cNeurons_
            nextNeuronSS += cNeurons_
            Debug.log(level: 189) {
                "display_.c2 \(layerSS + 1): \(nextNeuronSS) - \(nextNeuronSS + cNeurons)"
            }
            SceneDispatch.shared.schedule(c)
        }

        a()
    }
    // swiftlint:enable function_body_length
}
