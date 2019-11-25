import SpriteKit

enum Wangkhi {
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    static var spriteFactory: SpriteFactory!
    static let standardColor = 0x00_FF_00  // Slightly dim green
}

protocol WangkhiProtocol: class, Dispatchable {
    var birthday: Int { get set }
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var fishNumber: Int { get set }
    var gridCell: GridCell? { get set }
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var parent: Stepper? { get set }
    var sprite: SKSpriteNode? { get set }
}

enum Names {
    static var nameix = 0

    static var names = [
        "Alice", "Bob", "Charles", "David", "Ellen", "Felicity",
        "Grace", "Helen", "India", "James", "Karen", "Lizbeth",
        "Mary", "Nathan", "Olivia", "Paul", "Quincy", "Rob", "Samantha",
        "Tatiana", "Ulna", "Vivian", "William", "Xavier", "Yvonne", "Zoe"
    ]

    static func getName() -> String {
        defer { nameix += 1 }
        return names[nameix % names.count]
    }
}

final class WangkhiEmbryo: WangkhiProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var birthday = 0
    var callAgain = false
    var embryoName = Names.getName()
    var fishNumber = 0
    var gridCell: GridCell?
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var parent: Stepper?
    var sprite: SKSpriteNode?
    var tempStrongReference: Dispatch?
    var wiLaunch: DispatchWorkItem?
    var wiLaunch2: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Wangkhi", select: 1)
        self.parent = scratch.stepper
        self.tempStrongReference = scratch.dispatch

        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
        self.wiLaunch2 = DispatchWorkItem(flags: [], block: launch2_)
    }

    deinit {
        Log.L.write("~Wangkhi", select: 4)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        getStartingPosition()
        registerBirth()

        guard let w2 = wiLaunch2 else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w2)
    }

    func launch2_() {
        buildGuts()
        buildSprites()
    }
}

extension WangkhiEmbryo {
    private func getStartingPosition() {
        guard let parent = self.parent else {
            self.gridCell = GridCell.lockRandomCell(setOwner: embryoName)
            return
        }

        self.gridCell = GridCell.lockBirthPosition(parent: parent, setOwner: embryoName)
    }

    private func registerBirth() {
        World.stats.registerBirth_(myParent: nil, meOffspring: self)
    }
}

extension WangkhiEmbryo {
    func buildGuts() {
        Log.L.write("buildGuts", select: 1)
        defer { Log.L.write("~buildGuts") }
        metabolism = Metabolism()

        net = Net(
            parentBiases: parent?.parentBiases, parentWeights: parent?.parentWeights,
            layers: parent?.parentLayers, parentActivator: parent?.parentActivator
        )

        if let np = (sprite?.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(
                scene: scene, background: np, layers: net!.layers
            )

            netDisplay!.display()
        }
    }

}

extension WangkhiEmbryo {

    func buildSprites() {
        Log.L.write("buildSprites", select: 4)
        defer { Log.L.write("~buildSprites") }
        let action = SKAction.run { [unowned self] in
            Log.L.write("buildSprites1")
            self.buildSprites_()
            Log.L.write("buildSprites2")
        }

        GriddleScene.arkonsPortal.run(action) { [unowned self] in
            Log.L.write("buildSprites3")
            Grid.shared.concurrentQueue.async(flags: .barrier) { [unowned self] in
                Log.L.write("buildSprites4")
                self.releaseTempStrongReference()
                Log.L.write("buildSprites5")
            }
        }
    }

    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

        self.nose = Wangkhi.spriteFactory!.noseHangar.makeSprite()
        self.sprite = Wangkhi.spriteFactory!.arkonsHangar.makeSprite()

        guard let sprite = self.sprite else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let gridCell = self.gridCell else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.setScale(Wangkhi.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.setScale(0.5)
        sprite.position = gridCell.scenePosition
        sprite.alpha = 1

        sprite.addChild(nose)

        let newborn = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.parent
        newborn.dispatch.scratch.stepper = newborn

        Stepper.attachStepper(newborn, to: sprite)
    }

    func releaseTempStrongReference() {

        guard let sprite = self.sprite else { fatalError() }
        guard let gridCell = self.gridCell else { fatalError() }

        gridCell.sprite = sprite
        gridCell.contents = .arkon

        Log.L.write("launching newborn (sprite) \(spriteAKName(sprite)) at \(gridCell.gridPosition)")
        self.launchNewborn(at: gridCell)
        self.tempStrongReference = nil
        Log.L.write("two")
    }

    func launchNewborn(at gridCell: GridCell) {
        guard let sprite = self.sprite else { fatalError() }

        GriddleScene.arkonsPortal!.addChild(sprite)

        guard let newborn = sprite.getStepper() else { fatalError() }
        newborn.gridCell = gridCell

        if let dp = scratch?.dispatch, let st = scratch?.stepper {
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            dp.disengage(wiLaunch2)
        }

        guard let ndp = newborn.dispatch else { fatalError() }
        ndp.disengage(wiLaunch2)
    }
}
