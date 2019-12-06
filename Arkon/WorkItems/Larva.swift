import SpriteKit

protocol LarvaProtocol: class, DispatchableProtocol {
    var birthday: Int { get set }
    var callAgain: Bool { get }
    var cellConnector: HotKey? { get set }
    var dispatch: Dispatch? { get set }
    var fishNumber: Int { get set }
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

final class Larva: DispatchableProtocol, LarvaProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var birthday = 0
    var callAgain = false
    var cellConnector: HotKey?
    var embryoName = UUID().uuidString // Names.getName()
    var fishNumber = 0
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var parent: Stepper?
    var sprite: SKSpriteNode? { willSet {
        Log.L.write("Larva.sprite \(six(scratch?.stepper?.name))", level: 15)
    } }
    var tempStrongReference: Larva?
    var wiLaunch: DispatchWorkItem?
    var wiLaunch2: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Larva", level: 15)
        self.scratch = scratch
        self.parent = scratch.stepper
        self.tempStrongReference = self

        // Weak refs here, because apparently the work items capture self
        // even if you reference them with DispatchWorkItem(block: launch_)
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
        self.wiLaunch2 = DispatchWorkItem { [weak self] in self?.launch2_() }
    }

    deinit {
        Log.L.write("~Larva", level: 19)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
    }

    func launch_() {
        Log.L.write("Larva.launch_ \(six(scratch?.stepper?.name))", level: 15)

        getStartingPosition()
        registerBirth()

        guard let w2 = wiLaunch2 else { fatalError() }

        Grid.shared.serialQueue.async(execute: w2)
    }

    func launch2_() { buildSprites() }
}

extension Larva {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static let scaleFactor: CGFloat = 0.5 / ArkoniaCentral.masterScale
        static var spriteFactory: SpriteFactory!
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

extension Larva {
    private func getStartingPosition() {
        guard let parent = self.parent else {
            self.cellConnector = GridCell.lockRandomEmptyCell()
            return
        }

        self.cellConnector = GridCell.lockBirthPosition(parent: parent)
    }

    private func registerBirth() {
        World.stats.registerBirth(myParent: nil, meOffspring: self)
    }
}

extension Larva {
    func buildGuts() {

        metabolism = Metabolism()

        net = Net(
            parentBiases: parent?.parentBiases, parentWeights: parent?.parentWeights,
            layers: parent?.parentLayers, parentActivator: parent?.parentActivator
        )

        guard let sprite = self.sprite else { preconditionFailure() }

        buildNetDisplay(sprite)

        self.launchNewborn()
        self.tempStrongReference = nil
    }

}

extension Larva {

    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        guard let scene = np.parent as? SKScene else { return }

        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)
        netDisplay!.display()
    }
}

extension Larva {

    func abandonNewborn() {
        if let st = parent, let dp = st.dispatch, let sprite = st.sprite {
            let rotate = SKAction.rotate(byAngle: 4 * 2 * CGFloat.pi, duration: 2.0)
            sprite.run(rotate)
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            dp.metabolize()
        } else {
            Log.L.write("no scratch", level: 29)
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

        self.nose = Constants.spriteFactory!.noseHangar.makeSprite()
        self.sprite = Constants.spriteFactory!.arkonsHangar.makeSprite()

        guard let sprite = self.sprite else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let cellConnector = self.cellConnector else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.color = parent == nil ? .magenta : .yellow

        sprite.setScale(Constants.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.position = cellConnector.cell.scenePosition
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

        let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
        sprite.run(rotate)

        ndp.scratch.cellConnector = self.cellConnector
        ndp.disengage()
    }
}
