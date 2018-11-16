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
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var expresser = Expresser()
    private var brain: BrainProtocol!
    private var decoder: Decoder!
    private var vBrain: VBrain!
    
    override func didMove(to view: SKView) {
        #if true

        self.brain = Breeder.makeRandomBrain()
        decoder = Decoder(expresser: expresser)

        #else

        decoder = Decoder()
        self.brain = decoder.expresser.getBrain()

        #endif

        vBrain = VBrain(gameScene: self, brain: self.brain)

        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
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
        self.genome += Breeder.generateRandomGene()
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
    
    // With deepest gratitude to Stack Overflow dude
    // https://stackoverflow.com/users/2346164/gilian-joosen
    // https://stackoverflow.com/a/26787701/1610473
    //
    func returnChar(_ theEvent: NSEvent) -> Character? {
        let s: String = theEvent.characters!
        for char in s{ return char }
        return nil
    }

    override func keyUp(with event: NSEvent) {
//        let e = String(self.returnChar(event)!)
        self.genome += Breeder.generateRandomGene()
        decoder.setInput(to: self.genome).decode()
        self.brain = expresser.getBrain()
        self.brain.show()
        print(self.genome)

        update = true
    }
    
    var firstUpdate = true
    var update = true
    var genome = "b(42).W(-0.71562).W(-33.21311).N.A(false).W(-76.33163).A(false).W(-17.40379).t(-20.08699).A(true).t(-49.80827).W(-88.31035).t(-66.83028).N.A(false).A(false).L.b(87.97370).A(true).N.t(-47.82303)."
    var frameCount = 0
    override func update(_ currentTime: TimeInterval) {
        frameCount += 1

        if (frameCount % 30) == 0 && frameCount > 30 {
            #if true
            
//            self.brain = breeder.makeRandomBrain()

            #else
            _ = decoder.setInput(to: Utilities.generateGenome())
            decoder.decode()

            vBrain.setBrain(self.brain)
            #endif
        }
        
        if (frameCount % 15) == 0 && frameCount > 30 {
            if firstUpdate { firstUpdate = false; return }
            if !update { return }

            let rsi = self.brain.generateRandomSensoryInput()
            let outputs = self.brain.stimulate(sensoryInput: rsi)

            vBrain.displayBrain(self.brain)
            vBrain.tick(inputs: rsi, outputs: outputs)

            update = false
        }
    }
}

