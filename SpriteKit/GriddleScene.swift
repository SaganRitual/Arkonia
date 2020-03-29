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

    static var shared: GriddleScene!

    var clock: Clock?
    var hud: HUD!
    var readyForDisplayCycle = false

    let layers = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    static var arkonsPortal: SKSpriteNode!
    static var mannaPortal: SKSpriteNode!
    static var netPortal: SKSpriteNode!

    var barChartFactory: BarChartFactory!
    var bcNeurons: BarChart!

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

        bcNeurons = barChartFactory.newChart()
        bcNeurons.setChartLabel("Live Nodes")
        hud.placeMonitor(bcNeurons, dashboard: 0, quadrant: 3)

        bcNeurons.start()
    }

    func buildReports() {
        reportFactory = ReportFactory(hud: hud)

        reportSundry = reportFactory.newReport()
        reportSundry.setTitle("Sundry")
        reportSundry.setReportoid(1, label: "Nodes", data: "0")
        reportSundry.setReportoid(2, label: "Total births", data: "0")
        reportSundry.setReportoid(3, label: "", data: "")
        hud.placeMonitor(reportSundry, dashboard: 0, quadrant: 2)

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
        GriddleScene.mannaPortal = (childNode(withName: "manna_portal") as? SKSpriteNode)!
        GriddleScene.netPortal = (childNode(withName: "net_portal") as? SKSpriteNode)!

        Grid.shared = Grid(on: GriddleScene.arkonsPortal)
        Grid.shared.postInit()

        SpriteFactory.shared = SpriteFactory(scene: self)

        Debug.log(level: 38) { "GriddleScene.arkonsPortal scale = \(GriddleScene.arkonsPortal.xScale) x \(GriddleScene.arkonsPortal.yScale)" }

        self.scene!.delegate = self

        self.hud = HUD(scene: self)
        self.buildReports()
        self.buildBarCharts()

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

        SceneDispatch.tick()

        Display.displayCycle = .actions

        tickCount += 1
    }
}
