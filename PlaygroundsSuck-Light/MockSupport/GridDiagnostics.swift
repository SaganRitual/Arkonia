//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation
import SpriteKit

#if !NETCAMS_SMOKE_TEST
extension GameScene {
    
}

protocol VGridProtocol {
    var gameScene: GameScene { get }
    var labelBackground: SKShapeNode! { get set }
    var kNet: KNet { get set }
    var spacer: Spacer! { get set }
    var vBrainSceneSize: CGSize { get set }
    var vNeurons: [SKShapeNode] { get set }

    init(gameScene: GameScene, kNet: KNet, sceneSize: CGSize)

    func displayGrid(_ sensoryInputs: KLayer, _ motorOutputs: KLayer)
    func displayNet(_ sensoryInputs: KLayer, _ kNet: KNet, _ motorOutputs: KLayer)

    func displayLayers(_ sensoryInputs: KLayer, _ kLayers: [KLayer], _ motorOutputs: KLayer)
    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayerProtocol
}

protocol VLayerProtocol {
    var kLayer: KLayer { get }
    var spacer: Spacer { get }

    func drawConnections(to upperLayer: VLayerProtocol)
    func drawNeurons() -> [SKShapeNode]
    func drawParameters(on nodeLayer: [SKShapeNode], isSenseLayer: Bool)
}

extension VGridProtocol {
    func displayGrid(_ senseLayer: KLayer, _ motorLayer: KLayer) { displayNet(senseLayer, kNet, motorLayer) }

    func displayNet(_ senseLayer: KLayer, _ kNet: KNet, _ motorLayer: KLayer) {
        displayLayers(senseLayer, kNet.layers, motorLayer)
    }

    func displayLayers(_ senseLayer: KLayer, _ kLayers: [KLayer], _ motorLayer: KLayer) {
        var spacer = Spacer(netcam: gameScene, layersCount: kLayers.count)
        spacer.setDefaultCNeurons(senseLayer.neurons.count)
        spacer.layerType = .sensoryInputs

        var upperLayer = makeVLayer(kLayer: senseLayer, spacer: spacer)
        var nodeLayer = upperLayer.drawNeurons()
        upperLayer.drawParameters(on: nodeLayer, isSenseLayer: true)

        // Changes only the local copy, not the one we passed into
        // the upperLayer above.
        spacer.layerType = .hidden

        kLayers.forEach {
            spacer.setDefaultCNeurons($0.neurons.count)

            let lowerLayer = makeVLayer(kLayer: $0, spacer: spacer)
            lowerLayer.drawConnections(to: upperLayer)

            nodeLayer = lowerLayer.drawNeurons()
            lowerLayer.drawParameters(on: nodeLayer, isSenseLayer: false)

            upperLayer = lowerLayer
        }

        spacer.layerType = .motorOutputs
        spacer.setDefaultCNeurons(ArkonCentral.sel.howManyMotorNeurons)

        let bottomLayer = makeVLayer(kLayer: motorLayer, spacer: spacer)
        bottomLayer.drawConnections(to: upperLayer)
        _ = bottomLayer.drawNeurons()
    }
}

struct VGrid: VGridProtocol {
    var gameScene: GameScene
    var labelBackground: SKShapeNode!
    var kNet: KNet
    var spacer: Spacer!
    var vBrainSceneSize: CGSize
    var vNeurons = [SKShapeNode]()

    init(gameScene: GameScene, kNet: KNet, sceneSize: CGSize) {
        self.gameScene = gameScene
        self.kNet = kNet
        self.vBrainSceneSize = sceneSize
    }

    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayerProtocol {
        return VGLayer(netcam: gameScene, kLayer: kLayer, spacer: spacer)
    }
}

struct VGNet {
    let layers: [VGLayer]

    init(_ layers: [VGLayer]) { self.layers = layers }

}

struct VGLayer: VLayerProtocol {
    weak var gameScene: GameScene!
    let kLayer: KLayer
    let spacer: Spacer

    init(netcam: GameScene, kLayer: KLayer, spacer: Spacer) {
        self.gameScene = netcam; self.kLayer = kLayer; self.spacer = spacer
    }

    private func addNumericLabel(neuron: KNeuron, node: SKShapeNode, number: String, yOffset: CGFloat, drawAbove: Bool) -> CGFloat {
        let label = SKLabelNode(text: number)
        label.fontColor = .yellow
        label.fontName = "Courier New"
        label.fontSize = 16

        let background = SKShapeNode(rect: label.frame * 1.1)
        background.fillColor = gameScene.backgroundColor
        background.strokeColor = gameScene.backgroundColor
        background.position.y = yOffset - (2 * background.lineWidth) + (drawAbove ? background.frame.height : 0)

        background.addChild(label)
        node.addChild(background)

        return background.position.y
    }

    private func addBiasLabel(neuronSS: Int, node: SKShapeNode, yOffset: CGFloat) -> CGFloat {
        let neuron = kLayer.neurons[neuronSS]
        let bias = neuron.bias
        let biasString = bias.sciTruncate(5)

        return addNumericLabel(neuron: neuron, node: node, number: biasString, yOffset: yOffset, drawAbove: false)
    }

    private func addWeightLabel(neuronSS: Int, node: SKShapeNode, inputLine: Int, yOffset: CGFloat) -> CGFloat {
        let neuron = kLayer.neurons[neuronSS]
//        print("www \(neuron), ", terminator: "")
//        print("\(neuron.relay!.inputRelays)")
        let weightString = neuron.weights[inputLine].sciTruncate(5)

        return addNumericLabel(neuron: neuron, node: node, number: weightString, yOffset: yOffset, drawAbove: true)
    }

    func drawConnection(from: KIdentifier, to: KIdentifier, with upperLayerSpacer: Spacer) {
        let start = spacer.getPosition(xSS: from.myID, ySS: from.parentID)
        let end = upperLayerSpacer.getPosition(xSS: to.myID, ySS: to.parentID)

        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)

        line.strokeColor = .green
        gameScene.addChild(line)
    }

    func drawConnections(to upperLayer: VLayerProtocol) {
        kLayer.neurons.compactMap({ (neuron) -> KSignalRelay? in
            neuron.relay
        }).forEach { relay in
            var uniqueIDs = Set<KIdentifier>()

            relay.inputRelays.forEach { inputRelay in
                uniqueIDs.insert(inputRelay.id)
            }

            uniqueIDs.forEach { inputRelayID in
                drawConnection(from: relay.id, to: inputRelayID, with: upperLayer.spacer)
            }
        }
    }

    func drawNeurons() -> [SKShapeNode] {
        return kLayer.neurons.map { neuron in
            let vNeuron = SKShapeNode(circleOfRadius: 10)

            vNeuron.zPosition = 1.0
            vNeuron.fillColor = {
                if neuron.relay == nil { return .gray }

                switch spacer.layerType {
                case .hidden:         return .blue
                case .motorOutputs:   return .green
                case .sensoryInputs:  return .orange
                }
            }()

            vNeuron.position = spacer.getPosition(xSS: neuron.id.myID, ySS: neuron.id.parentID)
            gameScene.addChild(vNeuron)

            return vNeuron
        }
    }

    func drawParameters(on nodeLayer: [SKShapeNode], isSenseLayer: Bool = false) {
        kLayer.neurons.map({$0.relay})
        .enumerated().forEach { whichNeuron, relay_ in
            guard let relay = relay_ else { return }

            var yOffset = CGFloat(0.0)
            let node = nodeLayer[whichNeuron]

            if !isSenseLayer {
                for whichInput in 0..<relay.inputRelays.count {
                    yOffset = addWeightLabel(neuronSS: whichNeuron, node: node, inputLine: whichInput, yOffset: yOffset)
                }

                yOffset = addBiasLabel(neuronSS: whichNeuron, node: node, yOffset: -node.frame.height)
            }

            let thisIsUgly = kLayer.neurons[whichNeuron]
            let output = relay.output.sciTruncate(5)
            _ = addNumericLabel(neuron: thisIsUgly, node: node, number: output, yOffset: yOffset - node.frame.height, drawAbove: false)
        }
    }
}

struct VGNeuron {

}
#endif
