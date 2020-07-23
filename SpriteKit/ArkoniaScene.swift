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

    static var arkonsPortal: SKSpriteNode!
    static var netPortal: SKSpriteNode!
    static var netPortalHalfNeurons: SKSpriteNode!

    var barChartFactory: BarChartFactory!

    var lineGraphFactory: LineGraphFactory!
    var lgWeather: LineGraph!
    var lgFoodHits: LineGraph!

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

    override func keyDown(with event: NSEvent) { Census.shared.reSeedWorld() }

    func buildBarCharts() {
        barChartFactory = BarChartFactory(hud: hud)
    }

    func buildLineGraphs() {
        lineGraphFactory = LineGraphFactory(hud: hud, scene: self)

        lgWeather = lineGraphFactory.newGraph()
        lgFoodHits = lineGraphFactory.newGraph()

        lgWeather.setChartLabel("Almanac")
        lgFoodHits.setChartLabel("Food Hitrate")

        hud.placeDashoid(lgWeather, on: .middle, quadrant: 0, layoutId: .dashboards_portal_1x1)
        hud.placeDashoid(lgFoodHits, on: .middle, quadrant: 1, layoutId: .dashboards_portal_1x1)

        lgWeather.start(dataset: .weather)
        lgFoodHits.start(dataset: .foodHits)
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

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        let size = CGSize(width: 40, height: 40)
        let cube = SKShapeNode(rectOf: size)
        cube.fillColor = .red
        cube.position = location

        addChild(cube)
    }

    override func didMove(to view: SKView) {

        // Much gratitude to Jakub Charvat https://www.hackingwithswift.com/users/jakcharvat
        // https://www.hackingwithswift.com/forums/swiftui/swiftui-spritekit-macos-catalina-10-15/2662/2669

        backgroundColor = .black

        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
//        view.isAsynchronous = false
//        view.showsPhysics = true

        ArkoniaScene.shared = self

        ArkoniaScene.arkonsPortal =         SKSpriteNode(color: .black, size: view.scene!.size)
//        ArkoniaScene.netPortal =            loadScenePortal("net_9portals_backer")
//        ArkoniaScene.netPortalHalfNeurons = loadScenePortal("net_9portals_half_neurons_backer")

//        ArkoniaScene.arkonsPortal.color = .blue
//        ArkoniaScene.arkonsPortal.colorBlendFactor = 1
//        ArkoniaScene.arkonsPortal.alpha = 0.5
//        ArkoniaScene.arkonsPortal.zPosition = 100
        self.addChild(ArkoniaScene.arkonsPortal)

        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("spark-thorax-large")

        Grid.makeGrid(
            cellDimensionsPix: tTexture.size() / Arkonia.zoomFactor,
            portalDimensionsPix: ArkoniaScene.arkonsPortal.size,
            maxCSenseRings: NetStructure.cSenseRingsRange.upperBound,
            funkyCellsMultiplier: Arkonia.funkyCells
        )

        SpriteFactory.shared = SpriteFactory(scene: self)
        Census.shared.setupMarkers()

        Debug.log(level: 38) {
            "GriddleScene.arkonsPortal scale"
            + " = \(ArkoniaScene.arkonsPortal.xScale)"
            + " x \(ArkoniaScene.arkonsPortal.yScale)"
        }

        self.scene!.delegate = self

        MannaCannon.shared = MannaCannon()
        MannaCannon.shared.postInit()

        AKRandomNumberFakerator.shared = .init()

        self.run(SKAction.run {
            self.readyForDisplayCycle = true
            self.speed = 1
        })
    }

    // Safe only in SceneDispatch context
    static var currentSceneTime: TimeInterval = 0
    static var sceneBirthday: TimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        guard readyForDisplayCycle else { ArkoniaScene.sceneBirthday = currentTime; return }

        Display.displayCycle = .updateStarted

        ArkoniaScene.currentSceneTime = currentTime

        SceneDispatch.shared.tick()

        Display.displayCycle = .actions

        tickCount += 1
    }
}
