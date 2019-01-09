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

struct VLayer {
    weak var gameScene: GameScene!
    let kLayer: KLayer
    let spacer: Spacer

    init(netcam: GameScene, kLayer: KLayer, spacer: Spacer) {
        self.gameScene = netcam; self.spacer = spacer; self.kLayer = kLayer
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

    func drawConnections(to upperLayer: VLayer) {
        kLayer.neurons.forEach { neuron in
            guard let relay = neuron.relay else { return }

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
        return kLayer.neurons.compactMap { neuron in
            if neuron.relay == nil { return nil }

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

            print("drawNeurons() - layer \(kLayer) neurons \(kLayer.neurons.count) spacer \(spacer.cNeurons!) x = \(neuron.id.myID)")
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
