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

class KarambaScene: SKScene, ClockProtocol, SKSceneDelegate {

    private var tickCount = 0

    func didEvaluateActions(for scene: SKScene) {
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    var arkonsPortal: SKSpriteNode!
    let layers = [ArkoniaCentral.cSenseNeurons, 7, ArkoniaCentral.cMotorNeurons]
    var netDisplay: NetDisplay?
    var netPortal: SKSpriteNode!

    override func didMove(to view: SKView) {
        Display.currentTime = 0

        physicsWorld.gravity = CGVector.zero

        arkonsPortal = (childNode(withName: "arkons_portal") as? SKSpriteNode)!
        netPortal = (childNode(withName: "net_portal") as? SKSpriteNode)!

        let spriteFactory = SpriteFactory(
            scene: self,
            thoraxFactory: SpriteFactory.makeThorax(texture:),
            noseFactory: SpriteFactory.makeNose(texture:)
        )

        Manna.plantAllManna(background: arkonsPortal, spriteFactory: spriteFactory)

        Arkon.inject(self, layers, arkonsPortal, spriteFactory)

        NetDisplay(scene: self, background: netPortal, layers: layers).display()

        physicsWorld.contactDelegate = World.physicsCoordinator
        scene!.delegate = self
    }

    func getCurrentTime() -> TimeInterval { return Display.currentTime }

    override func update(_ currentTime: TimeInterval) {
        Display.displayCycle = .updateStarted

        defer {
            tickCount += 1
            Display.displayCycle = .actions
            Display.currentTime = currentTime
        }

        if tickCount < 10 { return }

        if tickCount == 10 {
            for _ in 0..<100 { Arkon.spawn(portal: arkonsPortal) }
            return
        }

        arkonsPortal.children.compactMap({ return $0 as? Thorax }).forEach {
            ($0 as SKSpriteNode).arkon.tick()
        }
    }
}
