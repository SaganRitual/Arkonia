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
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var parent: Stepper? { get set }
    var safeCell: SafeCell? { get set }
    var sprite: SKSpriteNode? { get set }
}

enum Names {
    static var nameix = 0

    static var names = [
        "Alice", "Bob", "Charles", "David", "Ellen", "Felicity",
        "Grace", "Helen", "India", "James", "Karen", "Lizbeth",
        "Mary", "Nathan", "Olivia", "Paul", "Quincy", "Rob", "Samantha",
        "Tatiana", "Ulna", "Vivian", "William", "Xavier", "Yvonne", "Zoe",

        "2Alice", "2Bob", "2Charles", "2David", "2Ellen", "2Felicity",
        "2Grace", "2Helen", "2India", "2James", "2Karen", "2Lizbeth",
        "2Mary", "2Nathan", "2Olivia", "2Paul", "2Quincy", "2Rob", "2Samantha",
        "2Tatiana", "2Ulna", "2Vivian", "2William", "2Xavier", "2Yvonne", "2Zoe",

        "3Alice", "3Bob", "3Charles", "3David", "3Ellen", "3Felicity",
        "3Grace", "3Helen", "3India", "3James", "3Karen", "3Lizbeth",
        "3Mary", "3Nathan", "3Olivia", "3Paul", "3Quincy", "3Rob", "3Samantha",
        "3Tatiana", "3Ulna", "3Vivian", "3William", "3Xavier", "3Yvonne", "3Zoe"
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
    var embryoName = UUID().uuidString // Names.getName()
    var fishNumber = 0
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var parent: Stepper?
    var safeCell: SafeCell?
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
        let hotCell: GridCell?

        defer {
            guard let hc = hotCell else { preconditionFailure() }
            self.safeCell = SafeCell(from: hc, takeOwnership: true)
        }

        guard let parent = self.parent else {
            hotCell = GridCell.lockRandomEmptyCell(setOwner: embryoName)
            return
        }

        hotCell = GridCell.lockBirthPosition(parent: parent, setOwner: embryoName)
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

        parent?.nose!.color = .white
        Log.L.write("build guts3", level: 16)

        guard let sprite = self.sprite else { preconditionFailure() }
        guard let safeCell = self.safeCell else { preconditionFailure() }

        safeCell.sprite = sprite
        safeCell.contents = .arkon

        buildNetDisplay(sprite)

        Log.L.write("launching newborn (sprite) \(six(sprite.name)) at \(safeCell.gridPosition)", level: 16)
        self.launchNewborn()
        self.tempStrongReference = nil
    }

}

extension WangkhiEmbryo {

    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        parent?.nose!.color = .cyan

        guard let scene = np.parent as? SKScene else { return }

        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)
        netDisplay!.display()
    }
}

extension WangkhiEmbryo {

    func abandonNewborn() {
        if let st = parent, let dp = st.dispatch {
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            dp.metabolize()
            parent?.nose!.color = .orange
        } else {
            Log.L.write("no scratch", level: 29)
            parent?.nose!.color = .yellow
        }
    }

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
        guard let gridCell = self.safeCell else { fatalError() }

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

    func launchNewborn() {
        guard let sprite = self.sprite else { preconditionFailure() }

        abandonNewborn()

        let newborn = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.parent
        newborn.dispatch.scratch.stepper = newborn

        Stepper.attachStepper(newborn, to: sprite)

        GriddleScene.arkonsPortal!.addChild(sprite)

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.setGridConnector(self.safeCell)
        ndp.disengage()
    }
}
