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
    
    private var brain: LayerOwnerProtocol!
    private var decoder: Decoder!
    private var vBrain: VBrain!

    var generationSS = 0
    var firstUpdate = true
    var update = true
//    var genome = "b(42).W(-0.71562).W(-33.21311).N.A(false).W(-76.33163).A(false).W(-17.40379).t(-20.08699).A(true).t(-49.80827).W(-88.31035).t(-66.83028).N.A(false).A(false).L.b(87.97370).A(true).N.t(-47.82303)."
    var frameCount = 0
    var currentGeneration = [Genome]()
    var selection = [Genome]()
    
    override func didMove(to view: SKView) {
        decoder = Decoder()

//        #if true
//        self.brain = Breeder.makeRandomBrain()
//        #else
//        self.brain = decoder.expresser.getBrain()
//        #endif

//        let howManyGenes = 50
        
//        let newGenome = testGenomes[0] //Breeder.generateRandomGenome(howManyGenes: howManyGenes)
        
//        Breeder.bb.setProgenitor(newGenome)
//        Breeder.bb.breedOneGeneration(10, from: newGenome)
        
//        _ = Breeder.bb.selectFromCurrentGeneration()
        
//        self.selection = [Genome]()
//        for _ in 0..<15 { self.selection.append(Breeder.generateRandomGenome(howManyGenes: 100)) }
        
//        for (ss, genome) in zip(0..., selection) {
//            print("Genome \(ss): ", genome)
//        }

//        self.selection.remove(at: 0)

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
        generationSS = 0
        update = true
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
    
    func nextBrain() {
        if selection.isEmpty { print("That's all, folks!"); fatalError() }
        
        let cg = selection.remove(at: 0)
        decoder.setInput(to: cg).decode()

        self.brain = Translators.t.getBrain()
        self.brain.show(tabs: "", override: false)
        
        vBrain.displayBrain(self.brain)
        
        update = true
    }

    override func keyUp(with event: NSEvent) {
        nextBrain()
    }
    
    var whichGenome = 1
    override func update(_ currentTime: TimeInterval) {
        frameCount += 1
        if frameCount < 120 { return }
        frameCount = 0

        decoder.setInput(to: testGenomes[whichGenome]).decode()
        self.brain = Translators.t.getBrain()
        vBrain = VBrain(gameScene: self, brain: self.brain)
        vBrain.displayBrain(self.brain)

        vBrain = VBrain(gameScene: self, brain: self.brain)
        vBrain.displayBrain(self.brain)
        self.brain.show(tabs: "")
//        whichGenome = (whichGenome + 1) % testGenomes.count
        whichGenome += 1
        if whichGenome >= testGenomes.count { exit(-1) }
        
    }

}

