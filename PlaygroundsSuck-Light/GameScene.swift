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
    static var gameScene: GameScene!

    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    #if NETCAMS_SMOKE_TEST
    var vnet: Vnet!
    var whichNetcam = Vnet.Quadrant.one
    var camtrack = 0

    override func sceneDidLoad() { vnet = Vnet(gameScene: self) }
    #endif

    #if SIGNAL_GRID_DIAGNOSTICS
    var decoder = Decoder()
    var gridAnchors: [KSignalRelay]!
    var gridDisplayed = false
    var kDriver: KDriver!
    var vGrid: VGrid!
    var vGridComplete = false

    override func sceneDidLoad() {
        ArkonCentral.gScene = self
    }

    func makeVGrid(_ kNet: KNet) {
        vGrid = VGrid(gameScene: self, kNet: kNet, sceneSize: self.frame.size)
        vGridComplete = true
    }
    #endif

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

    var frameCount = 0
    override func update(_ currentTime: TimeInterval) {
        defer {
            frameCount += 1
            self.lastUpdateTime = currentTime
        }

        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) { self.lastUpdateTime = currentTime }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime

        // Update entities
        for entity in self.entities { entity.update(deltaTime: dt) }

        #if NETCAMS_SMOKE_TEST
        displayTestPattern()
        #elseif SIGNAL_GRID_DIAGNOSTICS
        guard frameCount >= 120 && frameCount % 60 == 0 else { return }
        frameCount = 0  // Display only once for now

        self.removeAllChildren()

        let genome = Manipulator.makePassThruGenome(cLayers: 5)// RandomnessGenerator.generateRandomGenome(cGenes: 200)
        decoder.setInput(to: genome[...]).decode()

        kDriver = KDriver(tNet: decoder.tNet)
        kDriver.drive()

        gridAnchors = kDriver.transferGridAnchors()
        displaySignalGrid()
        #endif
    }
}
