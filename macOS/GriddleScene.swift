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

class GriddleScene: SKScene, ClockProtocol, SKSceneDelegate {

    private var tickCount = 0

    func didEvaluateActions(for scene: SKScene) {
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    var arkonsPortal: SKSpriteNode!
    var griddle: Griddle!
    var hud: HUD!
    let layers = [ArkoniaCentral.cSenseNeurons, 5, 5, 5, 5, ArkoniaCentral.cMotorNeurons]
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
        World.shared.currentTime = 0

        physicsWorld.gravity = CGVector.zero

        arkonsPortal = (childNode(withName: "arkons_portal") as? SKSpriteNode)!
        netPortal = (childNode(withName: "net_portal") as? SKSpriteNode)!

        // Figure out where the 475 comes from
        let origin = self.frame.origin + CGPoint(x: 480, y: 0)
        let re = CGRect(origin: origin, size: arkonsPortal.frame.size)
        arkonsPortal.physicsBody = SKPhysicsBody(edgeLoopFrom: re)

        enumerateChildNodes(withName: "net_9portal") { node_, _ in
            let node = (node_ as? SKSpriteNode)!
            self.net9Portals.append(node)
        }

        let spriteFactory = SpriteFactory(
            scene: self,
            thoraxFactory: SpriteFactory.makeThorax(texture:),
            noseFactory: SpriteFactory.makeNose(texture:)
        )

        spriteFactory.postInit(net9Portals)

        Arkon.inject(self, layers, arkonsPortal, spriteFactory)

        griddle = Griddle(arkonsPortal, spriteFactory)

        Manna.plantAllManna(background: arkonsPortal, spriteFactory: spriteFactory)

        physicsWorld.contactDelegate = World.physicsCoordinator
        scene!.delegate = self

        hud = HUD(scene: self)
        buildReports()
        //        buildBarCharts()
        //        buildLineGraphs()

        startCensus()
        startClock()
        //        startGenes()
        startOffspring()
    }

    func getCurrentTime() -> TimeInterval { return World.shared.currentTime }

    func startCensus() {
        let currentPopulation = reportArkonia.reportoid(2)
        let highWaterPopulation = reportMisc.reportoid(2)
        let highWaterAge = reportMisc.reportoid(1)
        let ageFormatter = DateComponentsFormatter()

        ageFormatter.allowedUnits = [.minute, .second]
        ageFormatter.allowsFractionalUnits = true
        ageFormatter.unitsStyle = .positional
        ageFormatter.zeroFormattingBehavior = .pad

        let updateAction = SKAction.run { [weak self] in
            currentPopulation.data.text = String(World.shared.population)
            highWaterPopulation.data.text = String(World.shared.maxPopulation)

            let portal = (self!.childNode(withName: "arkons_portal") as? SKSpriteNode)!

            let liveArkonsAges: [TimeInterval] = portal.children.compactMap {
                return ($0 as? SKSpriteNode)?.optionalStepper?.core.age
            }

            World.shared.greatestLiveAge = liveArkonsAges.max() ?? TimeInterval(0)

            highWaterAge.data.text = ageFormatter.string(from: Double(World.shared.maxAge))
        }

        let wait = SKAction.wait(forDuration: 0.43)
        let sequence = SKAction.sequence([wait, updateAction])
        let forever = SKAction.repeatForever(sequence)
        currentPopulation.data.run(forever)
    }

    func startClock() {
        let wait = SKAction.wait(forDuration: 1)

        let clockReport = reportArkonia.reportoid(1)
        let foodValueReport = reportArkonia.reportoid(3)
        let clockFormatter = DateComponentsFormatter()

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        let updateClockAction = SKAction.run {
            //            guard KarambaScene.isReadyForDisplay else { return }
            clockReport.data.text = clockFormatter.string(from: World.shared.gameAge)
        }

        let updateFoodValueAction = SKAction.run {
            //            guard KarambaScene.isReadyForDisplay else { return }
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

    func startOffspring() {
        let wait = SKAction.wait(forDuration: 2.3)

        let offspringReport = reportMisc.reportoid(3)

        let updateCOffspringAction = SKAction.run {
            //            guard KarambaScene.isReadyForDisplay else { return }
            offspringReport.data.text = String(format: "%d", World.shared.maxCOffspring)
        }

        let updateSequence = SKAction.sequence([wait, updateCOffspringAction])
        let offspringForever = SKAction.repeatForever(updateSequence)
        offspringReport.data.run(offspringForever)
    }

    override func update(_ currentTime: TimeInterval) {
        Display.displayCycle = .updateStarted

        if World.shared.timeZero == 0 { World.shared.timeZero = currentTime }

        defer {
            tickCount += 1
            Display.displayCycle = .actions
            World.shared.currentTime = currentTime
        }

        if tickCount < 10 { return }

        if tickCount >= 10 && tickCount <= 10  {
            Stepper.spawn(parentBiases: nil, parentWeights: nil, layers: nil)
        }

//        arkonsPortal.children.compactMap({ return $0 as? Thorax }).forEach {
//            let sprite = $0 as SKSpriteNode
//            sprite.arkon.tick()
//        }
    }
}
