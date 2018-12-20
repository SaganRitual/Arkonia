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
    let fontSizeForBrainLabel: CGFloat = 16.0
    let fontSizeForNeuronLabels: CGFloat = 12.0
    let gameScene: GameScene
    var isFinalUpdate = false
    var layers = [AKLayer]()
    var net: AKNet!
    var spacer: Spacer!
    var startingY: CGFloat = 0.0
    var vBrainSceneSize = CGSize()
    var vNeurons = [SKShapeNode]()
    var vTestInputs = [SKLabelNode]()
    var vTestOutputs = [SKLabelNode]()

    init(gameScene: GameScene, arkon: GSSubject) {
        if NSScreen.main?.frame == nil {
            fatalError("Something isn't working with the screen size")
        }

        self.gameScene = gameScene
        self.arkon = arkon
        self.net = arkon.brain.net!
    }

    func makeLightLabel() -> SKShapeNode {
        let lightLabel = SKLabelNode(text: arkon.lightLabel)
        lightLabel.fontSize = fontSizeForBrainLabel
        lightLabel.fontColor = .yellow
        lightLabel.fontName = "Courier New"

        let labelBackground = SKShapeNode(rect: lightLabel.frame)
        labelBackground.fillColor = gameScene.backgroundColor
        labelBackground.strokeColor = gameScene.backgroundColor
        labelBackground.addChild(lightLabel)
        labelBackground.position.y = -(gameScene.frame.size.height / 2.0) + labelBackground.frame.height
        labelBackground.zPosition = CGFloat(4.0)

        labelBackground.name = "labelBackground"

        return labelBackground
    }

    func displayBrain(_ net: AKNet? = nil, isFinalUpdate: Bool = false) {
        self.isFinalUpdate = isFinalUpdate

        let labelBackground = makeLightLabel()

        vBrainSceneSize = {
            var g = gameScene.size; g.height -= labelBackground.frame.height * 1.5; return g
        }()

        gameScene.removeAllChildren()
        gameScene.addChild(labelBackground)

        self.spacer = Spacer(layersCount: self.net.layers.count, displaySize: vBrainSceneSize)
        drawNeuronLayers(self.net.layers, spacer: spacer)
    }

    func reset() {
        net = nil
        vNeurons = [SKShapeNode]()
        vTestInputs = [SKLabelNode]()
        vTestOutputs = [SKLabelNode]()
    }

    struct Spacer {
        let layersCount: Int
        let displaySize: CGSize

        init(layersCount: Int, displaySize: CGSize) {
            self.layersCount = layersCount
            self.displaySize = displaySize
        }

        func getVSpacing() -> CGFloat {
            return displaySize.height / CGFloat(layersCount)
        }

        func getPosition(gameScene: GameScene, neuronsThisLayer: Int, xIndex: Int, yIndex: Int) -> CGPoint {
            guard let labelBackground = gameScene.childNode(withName: "labelBackground") else { preconditionFailure() }

            let vSpacing = getVSpacing()
            let vTop = (displaySize.height / 2.0) - (CGFloat(vSpacing) / 3.0) + labelBackground.frame.height

            let hSpacing = displaySize.width / CGFloat(neuronsThisLayer)
            let hLeft = (-displaySize.width + hSpacing) / 2.0

            return CGPoint(x: hLeft + CGFloat(xIndex) * hSpacing, y: vTop - CGFloat(yIndex) * vSpacing)
        }
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
            gameScene.addChild(line)
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
                    gameScene: gameScene, neuronsThisLayer: layer.neurons.count, xIndex: neuronSS, yIndex: layerSS
                )

                vNeuron.position = position
                currentLayerPoints.append(position)

                drawConnections(from: previousLayerPoints, to: neuron, at: position)
                drawOutputs(neuron, vNeuron)

                self.vNeurons.append(vNeuron)
                gameScene.addChild(vNeuron)
            }

            previousLayerPoints = currentLayerPoints
        }
    }

    func nilstr<T: CustomStringConvertible>(_ theOptional: T?, defaultString: String = "<nil>") -> String {
        var output = defaultString
        if let t = theOptional { output = "\(t)" }
        return output
    }

    func drawOutputs(_ neuron: AKNeuron, _ vNeuron: SKShapeNode) {
        let output = nilstr(neuron.relay?.output.sciTruncate(5), defaultString: "")
        let s = SKLabelNode(text: output)

        s.fontSize = fontSizeForNeuronLabels
        s.fontColor = NSColor.yellow
        s.fontName = "Courier New"

        let sklackground = SKShapeNode(rect: s.frame)
        sklackground.zPosition = CGFloat(2.0)
        sklackground.position = CGPoint()
        sklackground.fillColor = gameScene.backgroundColor
        sklackground.strokeColor = gameScene.backgroundColor
        sklackground.position.y = -(vNeuron.frame.size.height + sklackground.frame.size.height) / CGFloat(1.5)
        sklackground.addChild(s)
        vNeuron.addChild(sklackground)
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
