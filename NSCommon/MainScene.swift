import SpriteKit
import GameplayKit

class MainScene: SKScene {
    static var shared: MainScene!

    var barChartFactory: BarChartFactory!
    var bcAge: BarChart!
    var bcGenes: BarChart!
    var bcOffspring: BarChart!

    var lineGraphFactory: LineGraphFactory!
    var lgAge: LineGraph!
    var lgGenes: LineGraph!
    var lgOffspring: LineGraph!

    var netDiagramFactory: NetDiagramFactory!
    var netPortal: NetDiagram?

    var reportFactory: ReportFactory!
    var reportArkonia: Report!
    var reportMisc: Report!

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var hud: HUD!

    var tickCount = 0

    private var lastUpdateTime: TimeInterval = 0
    private static var alreadyDidMove = false
    private static var isReadyForDisplay = false

    func buildBarCharts() {
        barChartFactory = BarChartFactory(hud: hud)

        bcAge = barChartFactory.newChart()
        bcAge.setChartLabel("")
        hud.placeMonitor(bcAge, dashboard: 0, quadrant: 3)

        bcGenes = barChartFactory.newChart()
        bcGenes.setChartLabel("")
        hud.placeMonitor(bcGenes, dashboard: 1, quadrant: 0)

        bcOffspring = barChartFactory.newChart()
        bcOffspring.setChartLabel("")
        hud.placeMonitor(bcOffspring, dashboard: 1, quadrant: 3)

        bcAge.start()
        bcGenes.start()
        bcOffspring.start()
    }

    func buildLineGraphs() {
        lineGraphFactory = LineGraphFactory(hud: hud, scene: self)

        lgAge = lineGraphFactory.newGraph()
        lgAge.setChartLabel("Age")
        lgAge.pullDataAction = LineGraphUpdate.getAgeUpdater(lgAge)
        hud.placeMonitor(lgAge, dashboard: 0, quadrant: 2)

        lgGenes = lineGraphFactory.newGraph()
        lgGenes.maxInput = 500
        lgGenes.setChartLabel("Genes")
        lgGenes.pullDataAction = LineGraphUpdate.getCGeneUpdater(lgGenes)
        hud.placeMonitor(lgGenes, dashboard: 1, quadrant: 1)

        lgOffspring = lineGraphFactory.newGraph()
        lgOffspring.setChartLabel("Offspring")
        hud.placeMonitor(lgOffspring, dashboard: 1, quadrant: 2)

        lgAge.start()
        lgGenes.start()
    }

    func buildNetDiagram() {
        netDiagramFactory = NetDiagramFactory(hud: hud)
        netPortal = netDiagramFactory.newDiagram()
    }

    func buildReports() {
        reportFactory = ReportFactory(hud: hud, scene: self)

        reportMisc = reportFactory.newReport()
        reportMisc.setTitle("High Water")
        reportMisc.setReportoid(1, label: "Age", data: "0")
        reportMisc.setReportoid(2, label: "Genes", data: "0")
        reportMisc.setReportoid(3, label: "Population", data: "0")
        reportMisc.setReportoid(4, label: "Offspring", data: "0")
        hud.placeMonitor(reportMisc, dashboard: 0, quadrant: 0)

        reportArkonia = reportFactory.newReport()
        reportArkonia.setTitle("Arkonia")
        reportArkonia.setReportoid(1, label: "Clock", data: "00:00:00")
        reportArkonia.setReportoid(2, label: "Food", data: "0")
        reportArkonia.setReportoid(3, label: "Population", data: "0")
        reportArkonia.setReportoid(4, label: "Backlog", data: "0")
        hud.placeMonitor(reportArkonia, dashboard: 0, quadrant: 1)

        reportMisc.start()
        reportArkonia.start()
    }

    override func didMove(to view: SKView) {
        assert(MainScene.alreadyDidMove == false)
        MainScene.alreadyDidMove = true
        self.lastUpdateTime = 0

        MainScene.shared = self

        hud = HUD(scene: self)
        buildReports()
        buildBarCharts()
        buildLineGraphs()

        startBacklog()
        startCensus()
        startClock()
        startGenes()

        MainScene.isReadyForDisplay = true
    }

    func startBacklog() {
        let wait = SKAction.wait(forDuration: 1)

        let backlogReport = reportArkonia.reportoid(4)

        let updateBacklogAction = SKAction.run {
            backlogReport.data.text = String(Karamba.backlogCount)
        }

        let backlogSequence = SKAction.sequence([wait, updateBacklogAction])
        let backlogForever = SKAction.repeatForever(backlogSequence)
        backlogReport.data.run(backlogForever)
    }

    func startCensus() {
        let currentPopulation = reportArkonia.reportoid(3)
        let highWaterPopulation = reportMisc.reportoid(3)
        let highWaterAge = reportMisc.reportoid(1)
        let ageFormatter = DateComponentsFormatter()

        ageFormatter.allowedUnits = [.minute, .second]
        ageFormatter.allowsFractionalUnits = true
        ageFormatter.unitsStyle = .positional
        ageFormatter.zeroFormattingBehavior = .pad

        let updateAction = SKAction.run {
            currentPopulation.data.text = String(World.shared.population)
            highWaterPopulation.data.text = String(World.shared.maxPopulation)

            let portal = hardBind(
                Display.shared.scene?.childNode(withName: "arkons_portal") as? SKSpriteNode
            )

            let liveArkonsAges: [TimeInterval] = portal.children.compactMap {
                guard let k = $0 as? Karamba else { return nil }
                return k.age
            }

            World.shared.greatestLiveAge = liveArkonsAges.max() ?? 0

            highWaterAge.data.text = ageFormatter.string(from: World.shared.maxAge)
        }

        let wait = SKAction.wait(forDuration: 0.43)
        let sequence = SKAction.sequence([wait, updateAction])
        let forever = SKAction.repeatForever(sequence)
        currentPopulation.data.run(forever)
    }

    func startClock() {
        let wait = SKAction.wait(forDuration: 1)

        let clockReport = reportArkonia.reportoid(1)
        let foodValueReport = reportArkonia.reportoid(2)
        let clockFormatter = DateComponentsFormatter()

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        let updateClockAction = SKAction.run {
            guard MainScene.isReadyForDisplay else { return }
            clockReport.data.text = clockFormatter.string(from: Display.shared.gameAge)
        }

        let updateFoodValueAction = SKAction.run {
            guard MainScene.isReadyForDisplay else { return }
            let percentage = (1 - World.shared.entropy) * 100
            foodValueReport.data.text = String(format: "%.2f", percentage)
        }

        let clockSequence = SKAction.sequence([wait, updateClockAction])
        let clockForever = SKAction.repeatForever(clockSequence)
        clockReport.data.run(clockForever)

        let foodValueSequence = SKAction.sequence([wait, updateFoodValueAction])
        let foodValueForever = SKAction.repeatForever(foodValueSequence)
        foodValueReport.data.run(foodValueForever)
    }

    func startGenes() {
        let wait = SKAction.wait(forDuration: 1)

        let genesReport = reportMisc.reportoid(2)

        let updateCGenesAction = SKAction.run {
            guard MainScene.isReadyForDisplay else { return }
            genesReport.data.text = String(format: "%d", World.shared.maxCLiveGenes)
        }

        let updateSequence = SKAction.sequence([wait, updateCGenesAction])
        let genesForever = SKAction.repeatForever(updateSequence)
        genesReport.data.run(genesForever)
    }

    func touchDown(atPoint pos: CGPoint) {
    }

    func touchMoved(toPoint pos: CGPoint) {
    }

    func touchUp(atPoint pos: CGPoint) {
        Karamba.createDrones(100)
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
        guard MainScene.isReadyForDisplay else { return }

        defer { lastUpdateTime = currentTime }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime; return }

        if tickCount % 30 == 0 {
            hardBind(lgAge).addSamples(
                average: CGFloat(tickCount % Int(lgAge.maxInput - 1)),
                median: CGFloat(tickCount % Int(lgAge.maxInput - 2)),
                sum: CGFloat(tickCount % Int(lgAge.maxInput - 3))
            )

//            hardBind(lgGenes).addSamples(
//                average: CGFloat(tickCount % Int(lgAge.maxInput - 4)),
//                median: CGFloat(tickCount % Int(lgAge.maxInput - 5)),
//                sum: CGFloat(tickCount % Int(lgAge.maxInput - 6))
//            )
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        tickCount += 1

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
    }
}
