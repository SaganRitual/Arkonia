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
    static var displayCycle: DisplayCycle = .limbo
}

class GriddleScene: SKScene, SKSceneDelegate {
    private var tickCount = 0

    func didEvaluateActions(for scene: SKScene) {
//        asyncQueue.resume()
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    static var arkonsPortal: SKSpriteNode!
    static var arkonsArePresent: Bool = false
    static var shared: GriddleScene!

    var census: Census?
    var clock: Clock?
    var griddle: Grid!
    var hud: HUD!
    var readyForDisplayCycle = false

    let layers = [
        ArkoniaCentral.cSenseNeurons, ArkoniaCentral.cMotorNeurons, ArkoniaCentral.cMotorNeurons
    ]

    var netDisplay: NetDisplay?
    var netPortal: SKSpriteNode!
    var net9Portals = [SKSpriteNode]()

    var reportFactory: ReportFactory!
    var reportArkonia: Report!
    var reportMisc: Report!

    func buildReports() {
        reportFactory = ReportFactory(hud: hud)

        reportMisc = reportFactory.newReport()
        reportMisc.setTitle("High Water")
        reportMisc.setReportoid(1, label: "Age", data: "0")
        reportMisc.setReportoid(2, label: "Population", data: "0")
        reportMisc.setReportoid(3, label: "Offspring", data: "0")
        hud.placeMonitor(reportMisc, dashboard: 0, quadrant: 0)

        reportArkonia = reportFactory.newReport()
        reportArkonia.setTitle("Arkonia")
        reportArkonia.setReportoid(1, label: "Clock", data: "00:00:00")
        reportArkonia.setReportoid(2, label: "Population", data: "0")
        reportArkonia.setReportoid(3, label: "Food", data: "0")
        hud.placeMonitor(reportArkonia, dashboard: 0, quadrant: 1)

        reportMisc.start()
        //        reportArkonia.start()
    }

    override func didMove(to view: SKView) {
        GriddleScene.shared = self

        GriddleScene.arkonsPortal = (childNode(withName: "arkons_portal") as? SKSpriteNode)!
        GriddleScene.arkonsPortal.xScale = ArkoniaCentral.masterScale / 4
        GriddleScene.arkonsPortal.yScale = ArkoniaCentral.masterScale / 4

        Log.L.write("GriddleScene.arkonsPortal scale = \(GriddleScene.arkonsPortal.xScale) x \(GriddleScene.arkonsPortal.yScale)", level: 38)

        netPortal = (childNode(withName: "net_portal") as? SKSpriteNode)!

        enumerateChildNodes(withName: "net_9portal") { node_, _ in
            let node = (node_ as? SKSpriteNode)!
            self.net9Portals.append(node)
        }

        Spawn.Constants.spriteFactory = SpriteFactory(
            scene: self,
            thoraxFactory: SpriteFactory.makeSprite(texture:),
            noseFactory: SpriteFactory.makeSprite(texture:)
        )

        Spawn.Constants.spriteFactory.postInit(net9Portals)

        Grid.shared = Grid()
        MannaCoordinator.shared = MannaCoordinator()

        scene!.delegate = self

        hud = HUD(scene: self)
        buildReports()

//        clock = Clock(self)
//        census = Census(self)
        MannaCoordinator.shared.populate()

        readyForDisplayCycle = true
    }

    override func update(_ currentTime: TimeInterval) {
        guard readyForDisplayCycle else { return }

        if clock == nil { clock = Clock(self) }
        if census == nil { census = Census(self) }

        Display.displayCycle = .updateStarted

        Display.displayCycle = .actions

        tickCount += 1
    }
}
