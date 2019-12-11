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
    static var setix = 0

    static var names = [
        "Alice-", "Bob-", "Charles-",
        "David-", "Ellen-", "Felicity-",
        "Grace-", "Helen-", "India-",
        "James-", "Karen-", "Lizbeth-",
        "Mary-", "Nathan-", "Olivia-",
        "Paul-", "Quincy-", "Rob-",
        "Samantha-", "Tatiana-", "Ulna-",
        "Vivian-", "William-", "Xavier-",
        "Yvonne-", "Zoe-"
    ]

    static func getName() -> String {
        defer {
            nameix = (nameix + 1) % names.count
            if nameix == 0 { setix += 1 }
        }

        return names[nameix % names.count] + String(format: "%03d", setix)
    }
}

final class Larva: DispatchableProtocol, LarvaProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var birthday = 0
    var callAgain = false
    var cellConnector: HotKey?
    var embryoName = Names.getName()
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
//        cellConnector?.cell.ownerName = self.dispatch?.scratch.stepper?.name ?? "no fucking way"
        registerBirth()

        guard let w2 = wiLaunch2 else { fatalError() }

        Grid.shared.serialQueue.async(execute: w2)
    }

    func launch2_() { buildSprites() }
}

extension Larva {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static var spriteFactory: SpriteFactory!
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

extension Larva {
    private func getStartingPosition() {
        guard let parent = self.parent else {
            Log.L.write("Reset cellConnector #2", level: 41)
            self.cellConnector = GridCell.lockRandomEmptyCell()
//            self.cellConnector?.cell.ownerName = self.dispatch?.scratch.stepper?.name ?? "hella what"
            return
        }

        Log.L.write("Reset cellConnector #3", level: 41)
        self.cellConnector = GridCell.lockBirthPosition(parent: parent)
        self.cellConnector?.cell.ownerName = self.dispatch?.scratch.stepper?.name ?? "hecka what"
    }

    private func registerBirth() {
        World.stats.registerBirth(myParent: parent, meOffspring: self)
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
        Log.L.write("Reset cellConnector #4", level: 41)
        guard let cellConnector = self.cellConnector else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.color = parent == nil ? .magenta : .white

        sprite.setScale(ArkoniaCentral.masterScale / 8)
        Log.L.write("ArkoniaCentral.masterScale = \(ArkoniaCentral.masterScale)", level: 37)
        sprite.color = .red //ColorGradient.makeColor(hexRGB: 0xFF0000)
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

        Log.L.write("Reset cellConnector #5", level: 41)
        ndp.scratch.cellConnector = self.cellConnector
        ndp.disengage()
    }
}
