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

    static let dispatchQueue = DispatchQueue(
        label: "ak.scene", target: DispatchQueue.global(qos: .default)
    )

    static func serialize(_ function: @escaping (() -> Void)) {
        dispatchQueue.sync { function() }
    }

    static var shared: GriddleScene!

    var clock: Clock?
    var hud: HUD!
    var readyForDisplayCycle = false

    let layers = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    static var arkonsPortal: SKSpriteNode!

    var netDisplay: NetDisplay?
    var netPortal: SKSpriteNode!
    var net9Portals = [SKSpriteNode]()

    var reportFactory: ReportFactory!
    var reportArkonia: Report!
    var reportMisc: Report!

    //swiftlint:disable unused_setter_value
    override var isUserInteractionEnabled: Bool { get { true } set { } }
    //swiftlint:enable unused_setter_value

     override func mouseUp(with event: NSEvent) {
         let location = event.location(in: self)

        if atPoint(location).parent?.name == nil ||
             atPoint(location).parent!.name!.contains("Arkon") == false
        {
            self.isPaused = !self.isPaused
            return
        }

        print("Debug report for \(atPoint(location).parent!.name!)")

        Debug.showLog()
     }

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
        Substrate.shared = Substrate(on: GriddleScene.arkonsPortal)
        Substrate.shared.postInit()

        Debug.log("GriddleScene.arkonsPortal scale = \(GriddleScene.arkonsPortal.xScale) x \(GriddleScene.arkonsPortal.yScale)", level: 38)

        netPortal = (childNode(withName: "net_portal") as? SKSpriteNode)!

        enumerateChildNodes(withName: "net_9portal") { node_, _ in
            let node = (node_ as? SKSpriteNode)!
            self.net9Portals.append(node)
        }

        SpriteFactory.shared = SpriteFactory(
            scene: self,
            thoraxFactory: SpriteFactory.makeSprite(texture:),
            noseFactory: SpriteFactory.makeSprite(texture:)
        )

        SpriteFactory.shared.postInit(net9Portals) {
            self.scene!.delegate = self

            self.hud = HUD(scene: self)
            self.buildReports()

            Clock.shared = Clock(self)
            Banana.populateGarden()
            Census.shared = Census(self)

            self.readyForDisplayCycle = true
            self.speed = 1
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard readyForDisplayCycle else { return }

        Display.displayCycle = .updateStarted

        Display.displayCycle = .actions

        tickCount += 1
    }
}
