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

    init(gameScene: GameScene, testSubject: TSTestSubject) {
        guard let _ = NSScreen.main?.frame else {
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

        self.spacer = Spacer(layersCount: self.layers.count, displaySize: gameScene.size)
        drawNeuronLayers(self.layers, spacer: spacer)

        fishNumber = SKLabelNode(text: "\(testSubject.fishNumber)")
        gameScene.addChild(fishNumber)
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
            self.layersCount = layersCount
            self.displaySize = displaySize
        }
        
        func getVSpacing() -> Int {
            return Int(displaySize.height) / (layersCount + 1)
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
    func drawBiases(_ neuron: Translators.Neuron, _ vNeuron: SKShapeNode) {
        let b = SKLabelNode(text: "B(\(neuron.bias?.value ?? -42.42))")
        
//                let colors = [NSColor.blue, NSColor.green, NSColor.yellow, NSColor.red]
//                let whichColor = Int.random(in: 0..<colors.count)
        
        b.position = vNeuron.position
        b.fontSize = fontSize
        b.fontColor = NSColor.yellow
        b.fontName = "Courier New"
        b.position.x -= b.frame.width
//                b.position.x += (b.frame.width / 2)
        b.position.y += startingY
        startingY += b.frame.height
        gameScene.addChild(b)
    }

    func drawWeights(_ neuron: Translators.Neuron, _ vNeuron: SKShapeNode) {
        for ss in 0..<neuron.weights.count {
            let w = neuron.weights[ss]
            let s = SKLabelNode(text: "W(\(ss)) \(w.value)")
            
//                    let colors = [NSColor.blue, NSColor.green, NSColor.yellow, NSColor.red]
//                    let whichColor = Int.random(in: 0..<colors.count)
            
            s.position = vNeuron.position
            s.fontSize = fontSize
            s.fontColor = NSColor.green
            s.fontName = "Courier New"
            s.position.x -= s.frame.width
            s.position.y += startingY
            startingY += s.frame.height
            gameScene.addChild(s)
        }
    }

    func drawNeuronLayers(_ layers: [Translators.Layer], spacer: Spacer) {
        var previousLayerPoints = [CGPoint]()
    
        for (i, layer) in zip(0..., layers) {
            precondition(!layer.neurons.isEmpty, "Dead brain should not have come this far")
            
            let spacer = Spacer(layersCount: layers.count, displaySize: gameScene.frame.size)
            
            var currentLayerPoints = [CGPoint]()
            
            for (j, neuron) in zip(0..<layer.neurons.count, layer.neurons) {
                let vNeuron = SKShapeNode(circleOfRadius: 2)
                vNeuron.fillColor = .yellow
                
                let position = spacer.getPosition(neuronsThisLayer: layer.neurons.count, xIndex: j, yIndex: i)
                vNeuron.position = position
                currentLayerPoints.append(position)

                drawConnections(from: previousLayerPoints, to: neuron, at: position)
                
                self.vNeurons.append(vNeuron)
                gameScene.addChild(vNeuron)

//                if !isFinalUpdate {
//                    startingY = 0.0
//
//                    drawWeights(neuron, vNeuron)
//                    drawBiases(neuron, vNeuron)
//                }
            }
            
            previousLayerPoints = currentLayerPoints
//            print("p", previousLayerPoints)
        }
    }
    
    func drawConnections(from previousLayerPoints: [CGPoint], to neuron: Translators.Neuron, at neuronPosition: CGPoint) {
        if previousLayerPoints.isEmpty { return }
        for commLine in neuron.commLinesUsed {
            let linePath = CGMutablePath()

            linePath.move(to: neuronPosition)
            linePath.addLine(to: previousLayerPoints[commLine])
            
            let line = SKShapeNode(path: linePath)
            line.strokeColor = .green
            gameScene.addChild(line)
        }
    }
}
