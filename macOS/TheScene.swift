import SpriteKit
import GameplayKit

enum DisplayCycle: Int {
    case limbo
    case updateStarted
    case actions, actionsComplete
    case physics, physicsComplete
    case constraints, constraintsComplete
    case updateComplete

    func isIn(_ state: DisplayCycle) -> Bool { return self.rawValue == state.rawValue }
    func isPast(_ milestone: DisplayCycle) -> Bool { return self.rawValue >= milestone.rawValue }
}

struct Display {
    static var currentTime: TimeInterval = 0
    static var displayCycle: DisplayCycle = .limbo
}

class TheScene: SKScene, SKSceneDelegate {

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    private var tickCount = 0

    func didEvaluateActions(for scene: SKScene) {
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    override func didMove(to view: SKView) {
        Display.currentTime = 0

        physicsWorld.gravity = CGVector.zero

//        let background = (childNode(withName: "net_portal") as? SKSpriteNode)!
        let background = (childNode(withName: "arkons_portal") as? SKSpriteNode)!
        let spriteFactory = SpriteFactory(scene: self)
//
        Manna.contactTest(background: background, scene: self)
        Arkon.inject(spriteFactory, background)
        Arkon.contactTest()

//        Manna.grazeTest(background: background, scene: self)
//        Arkon.inject(spriteFactory, background)
//        Arkon.grazeTest()

//        NetDisplayGrid.selfTest(background: background)
//        NetGraphics.selfTest(background: background, scene: self)
//        SpriteFactory.selfTest(scene: self)

//        NetDisplay(scene: self, background: background).display(net: [12, 9, 9, 5])

//        Metabolism.selfTest()

        physicsWorld.contactDelegate = World.physicsCoordinator
        scene!.delegate = self
    }

    func touchDown(atPoint pos: CGPoint) {
    }

    func touchMoved(toPoint pos: CGPoint) {
    }

    func touchUp(atPoint pos: CGPoint) {
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

    override func update(_ currentTime: TimeInterval) {
        Display.displayCycle = .updateStarted

        defer {
            tickCount += 1
            Display.displayCycle = .actions
            Display.currentTime = currentTime
        }

        if tickCount < 10 { return }

        if Display.currentTime == 0 {

//            let background = (childNode(withName: "arkons_portal") as? SKSpriteNode)!
//            Maneuvers.selfTest(background: background, scene: self)
//            Manna.selfTest(background: background, scene: self)

            return
        }

        // Calculate time since last update
        let dt = currentTime - Display.currentTime

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
    }
}
