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
  

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    private var vnet: Vnet!
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0

        vnet = Vnet(gameScene: self)

    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    var whichNetcam = Vnet.Quadrant.one
    var camtrack = 0
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        if camtrack > 3 { return }

        let label = SKLabelNode(text: "Quadrant \(whichNetcam)")
        let netcam = vnet.getNetcam(whichNetcam)
        netcam.addChild(label)

        let layersCount = 12
        let neuronsPerLayerCount = 4
        let spacer = Spacer(netcam: netcam, layersCount: layersCount)
        var opacity = CGFloat(0.0)
        for y in 0..<layersCount {
            for x in 0..<neuronsPerLayerCount {
                let position = spacer.getPosition(neuronsThisLayer: neuronsPerLayerCount, xIndex: x, yIndex: y)

                let vNeuron = SKShapeNode(circleOfRadius: CGFloat(15.0))
                vNeuron.position = position

                vNeuron.alpha = opacity
                opacity += CGFloat(1.0) / CGFloat(layersCount * neuronsPerLayerCount)

                switch whichNetcam {
                case .one: vNeuron.fillColor = .blue
                case .two: vNeuron.fillColor = .green
                case .three: vNeuron.fillColor = .yellow
                case .four: vNeuron.fillColor = .purple
                }

                netcam.addChild(vNeuron)

                let label = SKLabelNode(text: "\(y):\(x)")
                label.fontColor = .black
                label.fontSize = 8
                label.fontName = "Courier New"
                label.position.x -= CGFloat(label.frame.width / 2)
                vNeuron.addChild(label)
            }
        }

        whichNetcam = whichNetcam.nextQuadrant(whichNetcam)
        camtrack += 1
    }
}
