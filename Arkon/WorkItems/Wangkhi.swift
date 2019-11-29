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
    var sprite: SKSpriteNode? { willSet {
        Log.L.write("Wangkhi.sprite \(six(scratch?.stepper?.name))", level: 15)
    } }
    var tempStrongReference: WangkhiEmbryo?
    var wiLaunch: DispatchWorkItem?
    var wiLaunch2: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Wangkhi", level: 15)
        self.scratch = scratch
        self.parent = scratch.stepper
        self.tempStrongReference = self

        // Weak refs here, because apparently the work items capture self
        // even if you reference them with DispatchWorkItem(block: launch_)
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
        self.wiLaunch2 = DispatchWorkItem { [weak self] in self?.launch2_() }
    }

    deinit {
        Log.L.write("~Wangkhi", level: 19)
    }

    func launch_() {
        Log.L.write("Wangkhi.launch_ \(six(scratch?.stepper?.name))", level: 15)

        getStartingPosition()
        registerBirth()

        guard let w2 = wiLaunch2 else { fatalError() }

        Grid.shared.serialQueue.async(execute: w2)
    }

    func launch2_() { buildSprites() }
}

extension WangkhiEmbryo {
    private func getStartingPosition() {
        guard let parent = self.parent else {
            self.gridCell = GridCell.lockRandomEmptyCell(setOwner: embryoName)
            return
        }

        self.gridCell = GridCell.lockBirthPosition(parent: parent, setOwner: embryoName)
    }

    private func registerBirth() {
        World.stats.registerBirth(myParent: nil, meOffspring: self)
    }
}

extension WangkhiEmbryo {
    func buildGuts() {
        Log.L.write("build guts1", level: 16)
        metabolism = Metabolism()

        Log.L.write("build guts2", level: 16)
        net = Net(
            parentBiases: parent?.parentBiases, parentWeights: parent?.parentWeights,
            layers: parent?.parentLayers, parentActivator: parent?.parentActivator
        )

        Log.L.write("build guts3", level: 16)

        guard let sprite = self.sprite else { preconditionFailure() }
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        Log.L.write("build guts4", level: 16)
        guard let scene = np.parent as? SKScene else { return }

        Log.L.write("build guts5", level: 16)
        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)

        Log.L.write("build guts6", level: 16)
        netDisplay!.display()
        Log.L.write("build guts7", level: 16)

        guard let gridCell = self.gridCell else { preconditionFailure() }

        gridCell.sprite = sprite
        gridCell.contents = .arkon

        Log.L.write("launching newborn (sprite) \(six(sprite.name)) at \(gridCell.gridPosition)", level: 16)
        self.launchNewborn(at: gridCell)
        self.tempStrongReference = nil
    }

}

extension WangkhiEmbryo {

    func buildSprites() {
        let action = SKAction.run { [unowned self] in
            self.buildSprites_()
            self.buildGuts()
        }

        GriddleScene.arkonsPortal.run(action)
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
    }

    func launchNewborn(at gridCell: GridCell) {
        guard let sprite = self.sprite else { preconditionFailure() }

        let newborn = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.parent
        newborn.dispatch.scratch.stepper = newborn

        Stepper.attachStepper(newborn, to: sprite)

        GriddleScene.arkonsPortal!.addChild(sprite)

        newborn.gridCell = gridCell

        if let dp = scratch?.dispatch, let st = scratch?.stepper {
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            dp.metabolize()
        }

        guard let ndp = newborn.dispatch else { fatalError() }
        ndp.disengage()
    }
}
