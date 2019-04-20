import SpriteKit
import GameplayKit

class MainScene: SKScene {

    var barChartFactory: BarChartFactory!
    var bcAge: BarChart!
    var bcGenes: BarChart!
    var bcOffspring: BarChart!

    var lineGraphFactory: LineGraphFactory!
    var lgAge: LineGraph!
    var lgGenes: LineGraph!
    var lgOffspring: LineGraph!

    var reportFactory: ReportFactory!
    var reportArkonia: Report!
    var reportMisc: Report!

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()
    var hud: HUD!

    var tickCount = 0

    private var lastUpdateTime: TimeInterval = 0
    private static var alreadyDidMove = false
    private static var readyForDisplay = false

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
        hud.placeMonitor(lgAge, dashboard: 0, quadrant: 2)

        lgGenes = lineGraphFactory.newGraph()
        lgGenes.setChartLabel("Genes")
        hud.placeMonitor(lgGenes, dashboard: 1, quadrant: 1)

        lgOffspring = lineGraphFactory.newGraph()
        lgOffspring.setChartLabel("Offspring")
        hud.placeMonitor(lgOffspring, dashboard: 1, quadrant: 2)
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
        reportArkonia.setReportoid(2, label: "", data: "")
        reportArkonia.setReportoid(3, label: "Population", data: "0")
        reportArkonia.setReportoid(4, label: "Food value", data: "0")
        hud.placeMonitor(reportArkonia, dashboard: 0, quadrant: 1)

        reportMisc.start()
        reportArkonia.start()
    }

    override func didMove(to view: SKView) {
        assert(MainScene.alreadyDidMove == false)
        MainScene.alreadyDidMove = true
        self.lastUpdateTime = 0

        hud = HUD(scene: self)
        buildReports()
        buildBarCharts()
        buildLineGraphs()

        MainScene.readyForDisplay = true
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
        guard MainScene.readyForDisplay else { return }

        defer { lastUpdateTime = currentTime }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime; return }

        //        hardBind(bcAge).addSample()

        //        if tickCount % 30 == 0 {
        //            hardBind(lgAge).addSamples(
        //                average: CGFloat(tickCount % Int(lgAge.maxInput - 1)),
        //                median: CGFloat(tickCount % Int(lgAge.maxInput - 2)),
        //                sum: CGFloat(tickCount % Int(lgAge.maxInput - 3))
        //            )

        //            hardBind(lgGenes).addSamples(
        //                average: CGFloat(tickCount % Int(lgAge.maxInput - 4)),
        //                median: CGFloat(tickCount % Int(lgAge.maxInput - 5)),
        //                sum: CGFloat(tickCount % Int(lgAge.maxInput - 6))
        //            )
        //        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        tickCount += 1

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
    }
}
