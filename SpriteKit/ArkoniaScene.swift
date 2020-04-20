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

class ArkoniaScene: SKScene, SKSceneDelegate {
    private var tickCount = 0

    func didEvaluateActions(for scene: SKScene) {
//        asyncQueue.resume()
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    static var shared: ArkoniaScene!

    var clock: Clock?
    var hud: HUD!
    var readyForDisplayCycle = false

    let layers = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    static var arkonsPortal: SKSpriteNode!
    static var netPortal: SKSpriteNode!
    static var netPortalHalfNeurons: SKSpriteNode!

    var barChartFactory: BarChartFactory!

    var lineGraphFactory: LineGraphFactory!
    var lgNeurons: LineGraph!
    var lgGenes: LineGraph!
    var lgOffspring: LineGraph!

    var reportArkonia: Report!
    var reportFactory: ReportFactory!
    var reportSundry: Report!
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

    func buildBarCharts() {
        barChartFactory = BarChartFactory(hud: hud)
    }

    func buildLineGraphs() {
        [0, 2].forEach {
            let p = hud.emptyMonitorFactory.newPlaceholder()
            hud.placeDashoid(p, on: .middle, quadrant: $0, layoutId: .dashboards_portal_1x2)
        }

        lineGraphFactory = LineGraphFactory(hud: hud, scene: self)

        lgNeurons = lineGraphFactory.newGraph()
        lgNeurons.setChartLabel("Neurons")

        hud.placeDashoid(lgNeurons, on: .middle, quadrant: 1, layoutId: .dashboards_portal_1x2)
//        hud.placeMonitor(lgNeurons, dashboard: 1, quadrant: 3)

//        lgGenes = lineGraphFactory.newGraph()
//        lgGenes.maxInput = 500
//        lgGenes.setChartLabel("Genes")
//        lgGenes.pullDataAction = LineGraphUpdate.getCGeneUpdater(lgGenes)
//        hud.placeMonitor(lgGenes, dashboard: 1, quadrant: 1)

//        lgOffspring = lineGraphFactory.newGraph()
//        lgOffspring.setChartLabel("Offspring")
//        hud.placeMonitor(lgOffspring, dashboard: 1, quadrant: 2)

        lgNeurons.start()
//        lgGenes.start()
    }

    func buildReports() {
        let p = hud.emptyMonitorFactory.newPlaceholder()
        hud.placeDashoid(p, on: .bottom, quadrant: 3, layoutId: .dashboards_portal_2x2)

        reportFactory = ReportFactory(hud: hud)

        reportMisc = reportFactory.newReport()
        reportMisc.setTitle("High Water")
        reportMisc.setReportoid(1, label: "Age", data: "0")
        reportMisc.setReportoid(2, label: "Population", data: "0")
        reportMisc.setReportoid(3, label: "Offspring", data: "0")

        hud.placeDashoid(
            reportMisc, on: .bottom, quadrant: 0, layoutId: .dashboards_portal_2x2
        )

        reportArkonia = reportFactory.newReport()
        reportArkonia.setTitle("Arkonia")
        reportArkonia.setReportoid(1, label: "Clock", data: "00:00:00")
        reportArkonia.setReportoid(2, label: "Population", data: "0")
        reportArkonia.setReportoid(3, label: "Food", data: "0")

        hud.placeDashoid(
            reportArkonia, on: .bottom, quadrant: 1, layoutId: .dashboards_portal_2x2
        )

        reportSundry = reportFactory.newReport()
        reportSundry.setTitle("Sundry")
        reportSundry.setReportoid(1, label: "All births", data: "0")
        reportSundry.setReportoid(2, label: "", data: "")
        reportSundry.setReportoid(3, label: "", data: "")

        hud.placeDashoid(
            reportSundry, on: .bottom, quadrant: 2, layoutId: .dashboards_portal_2x2
        )

        reportMisc.start()

        // We run the different elements of this report on separate threads,
        // only because I haven't gotten around to cleaning up the HUD yet
//        reportArkonia.start()
    }

    func loadScenePortal(_ portalName: String) -> SKSpriteNode {
        let portal = (childNode(withName: portalName) as? SKSpriteNode)!
        let x = (portal.userData!["x"] as? Int)!
        let y = (portal.userData!["y"] as? Int)!

        portal.position = CGPoint(x: x, y: y)
        return portal
    }

    override func didMove(to view: SKView) {
        ArkoniaScene.shared = self

        ArkoniaScene.arkonsPortal =         loadScenePortal("arkons_portal")
        ArkoniaScene.netPortal =            loadScenePortal("net_9portals_backer")
        ArkoniaScene.netPortalHalfNeurons = loadScenePortal("net_9portals_half_neurons_backer")

        ArkoniaScene.arkonsPortal.alpha = 1

        Grid.makeGrid(on: ArkoniaScene.arkonsPortal)

        SpriteFactory.shared = SpriteFactory(scene: self)

        Debug.log(level: 38) { "GriddleScene.arkonsPortal scale = \(ArkoniaScene.arkonsPortal.xScale) x \(ArkoniaScene.arkonsPortal.yScale)" }

        self.scene!.delegate = self

        self.hud = HUD(scene: self)
        self.hud.buildDashboards()
        self.buildReports()
        self.buildLineGraphs()
//        self.buildBarCharts()

        MannaCannon.shared = MannaCannon()
        MannaCannon.shared!.postInit()

        Clock.shared = Clock(self)
        Census.shared = Census(self)

        self.run(SKAction.run {
            self.readyForDisplayCycle = true
            self.speed = 1
        })
    }

    override func update(_ currentTime: TimeInterval) {
        guard readyForDisplayCycle else { return }

        Display.displayCycle = .updateStarted

        SceneDispatch.shared.tick()

        Display.displayCycle = .actions

        tickCount += 1
    }
}
