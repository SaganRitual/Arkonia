import SpriteKit

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

final class Spawn: DispatchableProtocol {
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

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.meTheParent = scratch.stepper
        self.tempStrongReference = self
    }

    func launch() { WorkItems.spawn(self) }
}

extension WorkItems {
    static func spawn(_ spawn: Spawn) {
        var newKey: HotKey?

        Debug.log("Spawn \(six(spawn.embryoName))", level: 71)

        func a() {
            getStartingPosition(spawn.fishDay, spawn.embryoName, spawn.meTheParent) {
                if let newKey = $0 {
                    spawn.engagerKey = newKey
                    spawn.meTheParent?.nose.color = .red
                    b()
                    return
                }

                Debug.log("Spawn failed \(six(spawn.meTheParent?.name)) \(six(spawn.embryoName))", level: 91)
                spawn.postponeSpawn()
            }
        }

        func b() {
            registerBirth(myName: spawn.embryoName, myParent: spawn.meTheParent)
                { spawn.fishDay = $0; c() }
        }

        func c() { spawn.buildArkon(d) }
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
    func buildGuts(_ onComplete: @escaping (Net) -> Void) {
        metabolism = Metabolism()

        Net.makeNet(
            parentBiases: meTheParent?.net.biases, parentWeights: meTheParent?.net.weights,
            layers: meTheParent?.net.layers, parentActivator: meTheParent?.net.activatorFunction
        ) { onComplete($0) }
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

        let rotate = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 0.25)
        sprite.run(rotate)

        let spawnCost = st.getSpawnCost()
        //        Debug.log("pre-spawn cost = \(spawnCost), remainder: \(st.metabolism.stomach.mass) \(st.metabolism.stomach.level) = \(st.metabolism.energyContent)", level: 74)
        st.metabolism.withdrawFromSpawn(spawnCost)
        st.metabolism.fatReserves.level = 0
        //        Debug.log("post-spawn cost = \(spawnCost), remainder: \(st.metabolism.stomach.mass) \(st.metabolism.stomach.level) = \(st.metabolism.energyContent)", level: 74)

        dp.metabolize()
    }

    func buildArkon(_ onComplete: @escaping () -> Void) {

        func a() {
            let action = SKAction.run { [unowned self] in self.buildSprites() }
            GriddleScene.shared.run(action, completion: b)
        }

        func b() { self.buildGuts { self.net = $0; c() } }

        func c() {
            let action = SKAction.run { [unowned self] in
                guard let sprite = self.thorax else { fatalError() }
                self.buildNetDisplay(sprite)
            }

            GriddleScene.shared.run(action, completion: onComplete)
        }

        a()
    }

    private func buildSprites() {
        assert(Display.displayCycle == .actions)

        self.nose = SpriteFactory.shared.noseHangar.makeSprite(embryoName)
        self.thorax = SpriteFactory.shared.arkonsHangar.makeSprite(embryoName)

        self.thorax!.addChild(self.nose!)

        guard let thorax = self.thorax else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let engagerKey = self.engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 0.5
        nose.setScale(Arkonia.noseScaleFactor)
        nose.zPosition = 6

        thorax.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        thorax.colorBlendFactor = 0.5
        thorax.position = engagerKey.scenePosition
        thorax.alpha = 1
        thorax.zPosition = 5

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
            Debug.log("launchNewborn.setContents", level: 80)
            self.launchB(ek, newborn)
        }
    }

    private func launchB(_ ek: HotKey, _ newborn: Stepper) {
        ek.sprite?.name = newborn.name
        ek.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: newborn.sprite)

        abandonNewborn()

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = ek

        let action = SKAction.run {
            Debug.log("launchB action", level: 85)
            GriddleScene.arkonsPortal.addChild(newborn.sprite)

            let rotate = SKAction.rotate(byAngle: -4 * 2 * CGFloat.pi, duration: 2.0)
            newborn.sprite.run(rotate)

            self.tempStrongReference = nil  // Now the sprite has the only strong ref
        }

        GriddleScene.arkonsPortal.run(action) {
            Substrate.serialQueue.async {
                Debug.log("launchB substrate", level: 85)
//                self.engagerKey = nil
                ndp.disengage()
            }
        }
    }
}

extension Spawn {
    func postponeSpawn() {
        guard let st = meTheParent, let dp = st.dispatch else { fatalError() }

        let failedSpawnCost = Arkonia.maxMannaEnergyContentInJoules
        st.metabolism.withdrawFromSpawn(failedSpawnCost)

        st.nose.color = .black
        dp.metabolize()
    }
}
