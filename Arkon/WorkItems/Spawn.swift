import SpriteKit

protocol SpawnProtocol: class, DispatchableProtocol {
    var birthday: Int { get set }
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var engagerKey: HotKey? { get set }
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

final class Spawn: DispatchableProtocol, SpawnProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var birthday = 0
    var callAgain = false
    var engagerKey: HotKey?
    let embryoName = Names.getName()
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
    var tempStrongReference: Spawn?
    var wiLaunch: DispatchWorkItem?
    var wiLaunch2: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Larva", level: 15)
        self.scratch = scratch
        self.parent = scratch.stepper
        self.tempStrongReference = self

        self.fishNumber = World.stats.getNextFishNumber_()

        // Weak refs here, because apparently the work items capture self
        // even if you reference them with DispatchWorkItem(block: launch_)
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
        self.wiLaunch2 = DispatchWorkItem { [weak self] in self?.launch2_() }
    }

    deinit {
        Log.L.write("~Larva \(six(embryoName))", level: 51)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
    }

    func launch_() {
        Log.L.write("Larva.launch_ \(six(scratch?.stepper?.name))", level: 15)

        getStartingPosition(self.embryoName)
//        engagerKey?.cell.ownerName = self.dispatch?.scratch.stepper?.name ?? "no fucking way"
        registerBirth()

        guard let w2 = wiLaunch2 else { fatalError() }

        Grid.shared.serialQueue.async(execute: w2)
    }

    func launch2_() { buildSprites() }
}

extension Spawn {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static var spriteFactory: SpriteFactory!
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

extension Spawn {
    private func getStartingPosition(_ embryoName: String) {
        guard let parent = self.parent else {
            engagerKey = GridCell.lockRandomEmptyCell(ownerName: "aboriginal-\(fishNumber)")
            Log.L.write("Larva engagerKey random empty cell at \(engagerKey?.gridPosition ?? AKPoint(x: -4242, y: -4242))", level: 52)
            return
        }

        engagerKey = GridCell.lockBirthPosition(parent: parent, name: embryoName)
        Log.L.write("Larva from \(six(parent.name)) engagerKey lock birth position at \(engagerKey?.gridPosition ?? AKPoint(x: -4242, y: -4242))", level: 52)
    }

    private func registerBirth() {
        World.stats.registerBirth(myParent: parent, meOffspring: self)
    }
}

extension Spawn {
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

extension Spawn {

    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        guard let scene = np.parent as? SKScene else { return }

        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)
        np.run(SKAction.run { self.netDisplay!.display() })
    }
}

extension Spawn {

    func abandonNewborn() {
        if let st = parent, let dp = st.dispatch, let sprite = st.sprite {
            let rotate = SKAction.rotate(byAngle: 4 * 2 * CGFloat.pi, duration: 2.0)
            sprite.run(rotate)
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            let ch = dp.scratch
            precondition(
                    (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                    ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                    ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition
            ))
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
        Log.L.write("Reset engagerKey #4", level: 41)
        guard let engagerKey = self.engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.color = parent == nil ? .orange : .yellow

        sprite.setScale(ArkoniaCentral.spriteScale)
        Log.L.write("ArkoniaCentral.masterScale = \(ArkoniaCentral.masterScale)", level: 37)
        sprite.color = .green //ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.position = engagerKey.scenePosition
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
        Log.L.write("Attach stepper \(six(newborn.name)) sprite name is \(six(sprite.name))", level: 51)

        GriddleScene.arkonsPortal!.addChild(sprite)

        let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
        sprite.run(rotate)

        guard let ndp = newborn.dispatch else { fatalError() }
        guard let ek = engagerKey else { fatalError() }

        Log.L.write("Spawn engagerKey contents = \(engagerKey!.contents), sprite name = \(six(engagerKey!.sprite?.name))", level: 52)
        ek.contents = .arkon
        ek.sprite = sprite

        precondition(ndp.scratch.stepper?.gridCell != nil)

        guard let ownerName = ek.sprite?.getStepper(require: false)?.name else { preconditionFailure() }
        ek.sprite?.name = ownerName

        Log.L.write("Spawn pre-transferKey  contents = \(ek.contents), sprite name = \(six(ek.sprite?.name)), at \(ek.gridPosition)/\(ek.sprite?.position ?? CGPoint.zero)", level: 55)
        ndp.scratch.engagerKey = ek
        Log.L.write("Spawn post-transferKey contents = \(ndp.scratch.engagerKey!.contents), sprite name = \(six(ndp.scratch.engagerKey!.sprite?.name)), at \(ndp.scratch.engagerKey!.gridPosition)/\(ndp.scratch.engagerKey!.sprite?.position ?? CGPoint.zero)", level: 55)
        precondition(ek.sprite?.getStepper(require: false) != nil)
        precondition(ndp.scratch.engagerKey?.sprite?.getStepper(require: false) != nil)
        precondition(ndp.scratch.engagerKey?.sprite?.getStepper(require: false)?.name == ek.sprite?.getStepper(require: false)?.name)

        Log.L.write("New stepper \(six(newborn.name)) has sprite \(six(sprite.name)), gridcell owned by \(six(ndp.scratch.stepper?.gridCell.ownerName))", level: 52)
        ndp.disengage()
    }
}
