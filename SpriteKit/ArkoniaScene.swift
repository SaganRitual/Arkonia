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

    override func didMove(to view: SKView) {
        AKRandomNumberFakerator.shared.fillArrays { self.didMove_(to: view) }
    }

    func didMove_(to view: SKView) {

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

        ArkoniaScene.arkonsPortal = SKSpriteNode(color: .black, size: view.scene!.size)

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
        Census.shared.start()
        Clock.shared.start()

        self.scene!.delegate = self

        MannaCannon.shared = MannaCannon()
        MannaCannon.shared.postInit()

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
