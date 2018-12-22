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

class VBrain {
    var arkon: GSSubject!
    var fishNumber = SKLabelNode()
    let fontSizeForBrainLabel: CGFloat = 30.0
    let fontSizeForNeuronLabels: CGFloat = 30.0
    let gameScene: GameScene
    var isFinalUpdate = false
    var labelBackground: SKShapeNode!
    var layers = [AKLayer]()
    let netcam: SKShapeNode!
    var spacer: Spacer!
    var startingY: CGFloat = 0.0
    var vBrainSceneSize = CGSize()
    var vnet: Vnet
    var vNeurons = [SKShapeNode]()
    var vTestInputs = [SKLabelNode]()
    var vTestOutputs = [SKLabelNode]()

    init(gameScene: GameScene) {
        if NSScreen.main?.frame == nil {
            fatalError("Something isn't working with the screen size")
        }

        self.gameScene = gameScene
        self.vnet = Vnet(gameScene: gameScene)
        self.netcam = self.vnet.netcams[0]
    }

    deinit { for netcam in vnet.netcams { netcam.removeAllChildren() } }

    func makeLightLabel(_ arkon: GSSubject) -> SKShapeNode {
        let lightLabel = SKLabelNode(text: arkon.lightLabel)
        lightLabel.fontSize = fontSizeForBrainLabel
        lightLabel.fontColor = .yellow
        lightLabel.fontName = "Courier New"

        labelBackground = SKShapeNode(rect: lightLabel.frame)
        labelBackground.fillColor = gameScene.backgroundColor
        labelBackground.strokeColor = gameScene.backgroundColor
        labelBackground.addChild(lightLabel)
        labelBackground.position.y = -netcam.frame.size.height + labelBackground.frame.height
        labelBackground.zPosition = CGFloat(4.0)

        return labelBackground
    }

    func displayBrain(_ arkon: GSSubject, isFinalUpdate: Bool = false) {
        self.isFinalUpdate = isFinalUpdate

        let labelBackground = makeLightLabel(arkon)

        vBrainSceneSize = {
            var g = netcam.frame.size; g.height -= labelBackground.frame.height / CGFloat(1.5); return g
        }()

        netcam.addChild(labelBackground)
        spacer = Spacer(netcam: netcam, layersCount: arkon.brain.net<!>.layers.count)

        drawNeuronLayers(arkon.brain.net<!>.layers, spacer: spacer)
    }
}

extension VBrain {

    func drawConnections(from previousLayerPoints: [CGPoint], to neuron: AKNeuron, at neuronPosition: CGPoint) {
        if previousLayerPoints.isEmpty { return }
        guard let relay = neuron.relay else { return }

        relay.inputs.forEach { relayAnchor in
            let linePath = CGMutablePath()

            linePath.move(to: neuronPosition)
            linePath.addLine(to: previousLayerPoints[relayAnchor.neuron.neuronID])

            let line = SKShapeNode(path: linePath)

            line.strokeColor = .green
            netcam.addChild(line)
        }
    }

    func drawNeuronLayers(_ layers: [AKLayer], spacer: Spacer) {
        var previousLayerPoints = [CGPoint]()

        layers.enumerated().forEach { layerSS, layer in
            precondition(!layer.neurons.isEmpty, "Dead brain should not have come this far")

            var currentLayerPoints = [CGPoint]()

            layer.neurons.enumerated().forEach { neuronSS, neuron in
                let vNeuron = SKShapeNode(circleOfRadius: 2)
                setNeuronColor(neuron, vNeuron)

                let position = spacer.getPosition(
                    neuronsThisLayer: layer.neurons.count, xIndex: neuronSS, yIndex: layerSS
                )

                vNeuron.position = position
                currentLayerPoints.append(position)

                drawConnections(from: previousLayerPoints, to: neuron, at: position)
                drawOutputs(neuron, vNeuron)

                self.vNeurons.append(vNeuron)
                netcam.addChild(vNeuron)
            }

            previousLayerPoints = currentLayerPoints
        }
    }

    func drawOutputs(_ neuron: AKNeuron, _ vNeuron: SKShapeNode) {
        let outputNetcam = vnet.netcams[3]
        let output = nilstr(neuron.relay?.output.sciTruncate(5), defaultString: "")
        let s = SKLabelNode(text: output)

        s.fontSize = fontSizeForNeuronLabels
        s.fontColor = NSColor.yellow
        s.fontName = "Courier New"

        let sklackground = SKShapeNode(rect: s.frame)
        sklackground.position = vNeuron.position
        sklackground.fillColor = gameScene.backgroundColor
        sklackground.strokeColor = gameScene.backgroundColor
        sklackground.position.y -= (vNeuron.frame.size.height + sklackground.frame.size.height) / CGFloat(1.5)
        sklackground.addChild(s)
        outputNetcam.addChild(sklackground)
    }

    func setNeuronColor(_ neuron: AKNeuron, _ vNeuron: SKShapeNode) {
        if neuron.relay == nil {
            vNeuron.fillColor = .darkGray
            vNeuron.strokeColor = .darkGray
        } else {
            vNeuron.fillColor = .yellow
            vNeuron.strokeColor = .white
        }
    }
}
