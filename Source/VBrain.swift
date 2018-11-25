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
    var brain: NeuralNetProtocol!
    let gameScene: GameScene
    var spacer: Spacer!
    var vNeurons = [SKShapeNode]()
    var vTestInputs = [SKLabelNode]()
    var vTestOutputs = [SKLabelNode]()
    var layers = [Translators.Layer]()
    
    init(gameScene: GameScene, brain: NeuralNetProtocol) {
        guard let _ = NSScreen.main?.frame else {
            fatalError("Something isn't working with the screen size")
        }
        
        self.gameScene = gameScene
        self.brain = brain
    }
    
    func displayBrain(_ brain: NeuralNetProtocol? = nil) {
        gameScene.removeAllChildren()

        if let b = brain { self.layers = b.layers }
        else { preconditionFailure("What the hell?") }

        self.spacer = Spacer(layersCount: self.layers.count, displaySize: gameScene.size)
        drawNeuronLayers(self.layers, spacer: spacer)
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
    
    func tick(inputs: [Double], outputs: [Double]) {
        gameScene.removeChildren(in: vTestInputs + vTestOutputs)
        
        let lambda = { (inputs: [Double], yIndex: Int) -> () in
            for (ix, input) in zip(0..., inputs) {
                let p = self.spacer.getPosition(neuronsThisLayer: inputs.count, xIndex: ix, yIndex: yIndex)
                let n = SKLabelNode(text: String(input))
                
                n.position = p
                
                self.vTestOutputs.append(n)
                self.gameScene.addChild(n)
            }
        }

        lambda(inputs, 0)
        lambda(outputs, outputs.count - 1)
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
    func drawNeuronLayers(_ layers: [Translators.Layer], spacer: Spacer) {
        var previousLayerPoints = [CGPoint]()
    
        for (i, layer) in zip(0..., layers) {
            if layer.neurons.isEmpty { print("No neurons in this layer"); continue }
            
            let spacer = Spacer(layersCount: layers.count, displaySize: gameScene.frame.size)
            
            var currentLayerPoints = [CGPoint]()
            
            for (j, neuron) in zip(0..<layer.neurons.count, layer.neurons) {
                let vNeuron = SKShapeNode(circleOfRadius: 2)
                vNeuron.fillColor = .yellow
                
                let position = spacer.getPosition(neuronsThisLayer: layer.neurons.count, xIndex: j, yIndex: i)
                vNeuron.position = position
                currentLayerPoints.append(position)

                var minusDeadCommLines = [CGPoint]()
                let cap = min(neuron.inputPortDescriptors.count, previousLayerPoints.count)
                for ss in 0..<cap {
                    let commLineNumber = neuron.inputPortDescriptors[ss]
                    minusDeadCommLines.append(previousLayerPoints[commLineNumber])
                }
                
//                print("m", minusDeadCommLines, "was", previousLayerPoints, "descriptor", neuron.inputPortDescriptors,
//                      "plp count", previousLayerPoints.count, "ipd count", neuron.inputPortDescriptors.count)

                if !minusDeadCommLines.isEmpty { drawConnections(from: minusDeadCommLines, to: neuron, at: position) }
                
                let fontSize: CGFloat = 8.0
                var startingY: CGFloat = 0.0
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

                self.vNeurons.append(vNeuron)
                gameScene.addChild(vNeuron)
            }
            
            previousLayerPoints = currentLayerPoints
//            print("p", previousLayerPoints)
        }
    }
    
    func drawConnections(from previousLayerPoints: [CGPoint], to neuron: Translators.Neuron, at neuronPosition: CGPoint) {
        for previousLayerPoint in previousLayerPoints {
            let linePath = CGMutablePath()
            linePath.move(to: neuronPosition)
            linePath.addLine(to: previousLayerPoint)
            
            let line = SKShapeNode(path: linePath)
            line.strokeColor = .green
            gameScene.addChild(line)
        }
    }
}
