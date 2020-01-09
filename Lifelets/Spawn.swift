import SpriteKit

protocol SpawnProtocol: class, DispatchableProtocol {
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var engagerKey: HotKey? { get set }
    var fishDay: Fishday { get set }
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var meTheParent: Stepper? { get set }
    var thorax: SKSpriteNode? { get set }
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

        let newName = names[nameix % names.count] + String(format: "%03d-Arkon", setix)
        return newName
    }
}

final class Spawn: DispatchableProtocol, SpawnProtocol {
    var dispatch: Dispatch? { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var callAgain = false
    var engagerKey: HotKey?
    let embryoName = Names.getName()
    var fishDay = Fishday(fishNumber: 0, birthday: 0)
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var meTheParent: Stepper?
    var thorax: SKSpriteNode?
    var tempStrongReference: Spawn?

    static let dispatchQueue = DispatchQueue(
        label: "ak.spawn.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.meTheParent = scratch.stepper
        self.tempStrongReference = self
    }

    func launch() { WorkItems.spawn(self) }
}

extension WorkItems {
    static func spawn(_ spawn: Spawn) {

        Debug.log("Spawn \(six(spawn.embryoName))", level: 71)
        func a() {
            registerBirth(myName: spawn.embryoName, myParent: spawn.meTheParent)
                { spawn.fishDay = $0; b() }
        }

        func b() {
            getStartingPosition(spawn.fishDay, spawn.embryoName, spawn.meTheParent)
                { spawn.engagerKey = $0; c($0) }
        }

        func c(_ engagerKey: HotKey?) { spawn.buildArkon(engagerKey, d) }
        func d() { WorkItems.launchNewborn(spawn) }

        a()
    }
}

extension WorkItems {
    typealias onCompleteHotKey = (HotKey?) -> Void

    static private func getStartingPosition(
        _ fishDay: Fishday, _ embryoName: String, _ meTheParent: Stepper?, _ onComplete: @escaping onCompleteHotKey
    ) {
        Substrate.serialQueue.async {
            let key = getStartingPosition(fishDay, embryoName, meTheParent)
            onComplete(key)
        }
    }

    static private func getStartingPosition(
        _ fishDay: Fishday, _ embryoName: String, _ meTheParent: Stepper?
    ) -> HotKey? {
        guard let parent = meTheParent else {
            return GridCell.lockRandomEmptyCell(
                ownerName: "aboriginal-\(fishDay.fishNumber)"
            )
        }

        return GridCell.lockBirthPosition(parent: parent, name: embryoName)
    }
}

extension Spawn {
    enum Constants {
        static let brightColor = 0x00_FF_00    // Full green
        static let standardColor = 0x00_FF_00  // Slightly dim green
    }
}

typealias OnComplete0p = () -> Void
typealias OnComplete1p = (HotKey?) -> Void

extension Spawn {
    func buildGuts() {
        metabolism = Metabolism()

        net = Net(
            parentBiases: meTheParent?.parentBiases, parentWeights: meTheParent?.parentWeights,
            layers: meTheParent?.parentLayers, parentActivator: meTheParent?.parentActivator
        )

        guard let sprite = self.thorax else { fatalError() }
        buildNetDisplay(sprite)
    }

}

extension Spawn {

    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        guard let scene = np.parent as? SKScene else { return }

        netDisplay = NetDisplay(scene: scene, background: np, layers: net!.layers)
        netDisplay!.display()
    }
}

extension Spawn {

    func abandonNewborn() {
        guard let st = meTheParent, let dp = st.dispatch, let sprite = st.sprite
            else { return }

        let rotate = SKAction.rotate(byAngle: 4 * 2 * CGFloat.pi, duration: 2.0)
        sprite.run(rotate)

        let spawnCost = st.getSpawnCost()
        //        Debug.log("pre-spawn cost = \(spawnCost), remainder: \(st.metabolism.stomach.mass) \(st.metabolism.stomach.level) = \(st.metabolism.energyContent)", level: 74)
        st.metabolism.withdrawFromSpawn(spawnCost)
        st.metabolism.fatReserves.level = 0
        //        Debug.log("post-spawn cost = \(spawnCost), remainder: \(st.metabolism.stomach.mass) \(st.metabolism.stomach.level) = \(st.metabolism.energyContent)", level: 74)

        dp.metabolize()
    }

    func buildArkon(_ engagerKey: HotKey?, _ onComplete: @escaping () -> Void) {
        let action = SKAction.run { [unowned self] in
            assert(Display.displayCycle == .actions)
            self.buildSprites(engagerKey)
            self.thorax!.addChild(self.nose!)
            self.buildGuts()
        }

        GriddleScene.shared.run(action, completion: onComplete)
    }

    private func buildSprites(_ engagerKey: HotKey?) {
        assert(Display.displayCycle == .actions)

        self.nose = SpriteFactory.shared.noseHangar.makeSprite(embryoName)
        self.thorax = SpriteFactory.shared.arkonsHangar.makeSprite(embryoName)

        guard let thorax = self.thorax else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let engagerKey = engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 0.5
        nose.setScale(Arkonia.noseScaleFactor)

        thorax.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        thorax.colorBlendFactor = 0.5
        thorax.position = engagerKey.scenePosition
        thorax.alpha = 1

        let noseColor: SKColor = (meTheParent == nil) ? .magenta : .yellow
        Debug.debugColor(thorax, .green, nose, noseColor)
    }
}

extension WorkItems {
    static func launchNewborn(_ spawn: Spawn) {
        Substrate.serialQueue.async(execute: spawn.launchNewborn)
    }
}

extension Spawn {
    func launchNewborn() {
        let newborn = Stepper(self, needsNewDispatch: true)
        precondition(newborn.sprite.parent == nil)
        newborn.parentStepper = self.meTheParent
        newborn.dispatch.scratch.stepper = newborn
        newborn.sprite?.color = .yellow
        newborn.nose?.color = .white

        guard let ek = engagerKey else { fatalError() }

        precondition(newborn.name == newborn.sprite.name)
        precondition((thorax?.name ?? "foo") == newborn.sprite.name)

        ek.bell?.setContents(to: .arkon, newSprite: newborn.sprite) {
            self.launchB(ek, newborn)
        }
    }

    private func launchB(_ ek: HotKey, _ newborn: Stepper) {
        ek.sprite?.name = newborn.name
        ek.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: newborn.sprite)
        self.tempStrongReference = nil  // Now the sprite has the only strong ref

        abandonNewborn()

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = ek

        let action = SKAction.run {
            GriddleScene.arkonsPortal.addChild(newborn.sprite)

            let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
            newborn.sprite.run(rotate)
        }

        GriddleScene.arkonsPortal.run(action) {
            Substrate.serialQueue.async {
                self.engagerKey = nil
                ndp.disengage()
            }
        }
    }
}
