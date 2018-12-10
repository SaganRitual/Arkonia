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
    var testSubject: TSTestSubject!
    var brain: NeuralNetProtocol!
    let gameScene: GameScene
    var spacer: Spacer!
    var fishNumber = SKLabelNode()
    var vNeurons = [SKShapeNode]()
    var vTestInputs = [SKLabelNode]()
    var vTestOutputs = [SKLabelNode]()
    var layers = [Translators.Layer]()
    var isFinalUpdate = false
    let fontSize: CGFloat = 8.0
    var startingY: CGFloat = 0.0

    var vBrainSceneSize = CGSize()

    init(gameScene: GameScene, testSubject: TSTestSubject) {
        if NSScreen.main?.frame == nil {
            fatalError("Something isn't working with the screen size")
        }

        self.gameScene = gameScene
        self.testSubject = testSubject
        self.brain = testSubject.brain
    }

    func displayBrain(_ brain: NeuralNetProtocol? = nil, isFinalUpdate: Bool = false) {
        self.isFinalUpdate = isFinalUpdate

        gameScene.removeAllChildren()

        if let b = brain { self.layers = b.layers }
        else { preconditionFailure("What the hell?") }

        vBrainSceneSize = gameScene.size; vBrainSceneSize.height *= 0.9; vBrainSceneSize.width *= 0.9
//        print("gameScene.size = (\(vBrainSceneSize.width), \(vBrainSceneSize.height))")

        self.spacer = Spacer(layersCount: self.layers.count, displaySize: vBrainSceneSize)
        drawNeuronLayers(self.layers, spacer: spacer)

        fishNumber = SKLabelNode(text: "\(testSubject.fishNumber)")
        let sklackground = SKShapeNode(rect: fishNumber.frame)
        sklackground.fillColor = .black
        sklackground.strokeColor = .black
        sklackground.addChild(fishNumber)
        sklackground.zPosition = CGFloat(3.0)
        gameScene.addChild(sklackground)
    }

    func reset() {
        brain = nil
        vNeurons = [SKShapeNode]()
        vTestInputs = [SKLabelNode]()
        vTestOutputs = [SKLabelNode]()
    }

    func setBrain(_ brain: NeuralNetProtocol) {
        self.brain = brain
    }

    struct Spacer {
        let layersCount: Int
        let displaySize: CGSize

        init(layersCount: Int, displaySize: CGSize) {
            self.layersCount = layersCount + 1
            self.displaySize = displaySize
        }

        func getVSpacing() -> Int {
            return Int(displaySize.height) / layersCount
        }

        func getPosition(neuronsThisLayer: Int, xIndex: Int, yIndex: Int) -> CGPoint {
            let vSpacing = getVSpacing()
            let vTop = Int(displaySize.height) / 2 - vSpacing

            let hSpacing = Int(displaySize.width) / neuronsThisLayer
            let hLeft = (Int(-displaySize.width) + hSpacing) / 2

            return CGPoint(x: hLeft + xIndex * hSpacing, y: vTop - yIndex * vSpacing)
        }
    }
}

extension VBrain {

    func drawConnections(from previousLayerPoints: [CGPoint], to neuron: Translators.Neuron, at neuronPosition: CGPoint) {
        if previousLayerPoints.isEmpty { return }

        for commLine in neuron.commLinesUsed {
            let linePath = CGMutablePath()

            linePath.move(to: neuronPosition)
            linePath.addLine(to: previousLayerPoints[commLine])

            let line = SKShapeNode(path: linePath)

            setConnectionColor(neuron, line)

            gameScene.addChild(line)
        }
    }

    func drawNeuronLayers(_ layers: [Translators.Layer], spacer: Spacer) {
        var previousLayerPoints = [CGPoint]()

        for (i, layer) in zip(0..., layers) {
            precondition(!layer.neurons.isEmpty, "Dead brain should not have come this far")

            var currentLayerPoints = [CGPoint]()

            for (j, neuron) in zip(0..<layer.neurons.count, layer.neurons) {
                let vNeuron = SKShapeNode(circleOfRadius: 2)
                setNeuronColor(neuron, vNeuron)

                let position = spacer.getPosition(neuronsThisLayer: layer.neurons.count, xIndex: j, yIndex: i)
                vNeuron.position = position
                currentLayerPoints.append(position)

                drawConnections(from: previousLayerPoints, to: neuron, at: position)
                drawOutputs(neuron, vNeuron)

                self.vNeurons.append(vNeuron)
                gameScene.addChild(vNeuron)
            }

            previousLayerPoints = currentLayerPoints
//            print("p", previousLayerPoints)
        }
    }

    func drawOutputs(_ neuron: Translators.Neuron, _ vNeuron: SKShapeNode) {
        guard ((neuron.hasOutput && neuron.hasClients) || neuron.isMotorNeuron),
                let hisOutput = neuron.myTotalOutput else { return }

        let output = "\(hisOutput.sciTruncate(5))"
        let s = SKLabelNode(text: output)

        s.fontSize = fontSize
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

    func setConnectionColor(_ neuron: Translators.Neuron, _ line: SKShapeNode) {
        if (neuron.hasClients && neuron.hasOutput) || neuron.isMotorNeuron {
            line.strokeColor = .green
        } else if !neuron.hasOutput {
            line.strokeColor = .red// I think this won't happen
        } else if !neuron.hasClients {
            line.strokeColor = .gray
        }
    }

    func setNeuronColor(_ neuron: Translators.Neuron, _ vNeuron: SKShapeNode) {
        if (neuron.hasOutput && neuron.hasClients) || neuron.isMotorNeuron {
            vNeuron.fillColor = .yellow
            vNeuron.strokeColor = .white
        } else if !neuron.hasOutput {
            vNeuron.fillColor = .red
            vNeuron.strokeColor = .red
        } else {  // No clients
            vNeuron.fillColor = .blue
            vNeuron.strokeColor = .blue
        }
    }
}
