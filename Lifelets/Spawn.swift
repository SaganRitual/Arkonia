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

    var birthplace: HotKey?
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
        self.birthplace = scratch.senseGrid?.getRandomEmptyHotKey()
        self.tempStrongReference = self

        Debug.log(level: 117) {
            return "Spawn: parent \(six(meTheParent?.name))"
                + " at \(String(describing: meTheParent?.gridCell?.gridPosition))"
                + " spawns \(six(embryoName))"
                + " at \(String(describing: birthplace?.gridPosition))"
        }
    }

    func launch() { WorkItems.spawn(self) }
}

extension WorkItems {
    static func spawn(_ spawn: Spawn) {
        var newKey: HotKey?

        Debug.log(level: 117) { "Spawn1 \(six(spawn.embryoName)) at \(six(spawn.birthplace?.gridPosition))" }

        func a() {
            if spawn.birthplace == nil {
                Debug.log(level: 117) { "Spawn2.5 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
                getStartingPosition(spawn.fishDay, spawn.embryoName, spawn.meTheParent) {
                    newKey = $0
                    Debug.log(level: 117) { "Spawn3 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
                    b()
                }

                return
            }

            newKey = spawn.birthplace
            Debug.log(level: 117) { "Spawn2 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
            b()
        }

        func b() {
            if newKey == nil {
                Debug.log(level: 117) { "Spawn4 \(six(spawn.embryoName)) no available cell; postpone spawn" }
                spawn.postponeSpawn()
            } else { c() }
        }

        func c() {
            Debug.log(level: 117) { "Spawn5 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
            spawn.engagerKey = newKey
            spawn.meTheParent?.nose.color = .yellow

            registerBirth(myName: spawn.embryoName, myParent: spawn.meTheParent)
                { spawn.fishDay = $0; d() }
        }

        func d() {
            Debug.log(level: 117) { "Spawn5.5 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
            spawn.buildArkon(e) }
        func e() {
            Debug.log(level: 117) { "Spawn6 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
            WorkItems.launchNewborn(spawn)
            Debug.log(level: 117) { "Spawn7 \(six(spawn.embryoName)) alternate birthplace at \(six(newKey))" }
       }

        a()
    }
}

extension WorkItems {
    typealias onCompleteHotKey = (HotKey?) -> Void

    static private func getStartingPosition(
        _ fishDay: Fishday, _ embryoName: String, _ meTheParent: Stepper?, _ onComplete: @escaping onCompleteHotKey
    ) {
        Grid.serialQueue.async {
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

        return parent.dispatch.scratch.senseGrid?.cells
            .dropFirst()
            .compactMap({ $0 as? HotKey })
            .filter({ !$0.contents.isOccupied && $0.ownerName == parent.name })
            .randomElement()
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
            parentBiases: meTheParent?.net.biases.map({ Double($0) }), parentWeights: meTheParent?.net.weights.map({ Double($0) }),
            layers: meTheParent?.net.layers, parentActivator: meTheParent?.net.activatorFunction
        ) { onComplete($0) }
    }
}

extension Spawn {
    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        guard let hp = (sprite.userData?[SpriteUserDataKey.netHalfNeuronsPortal] as? SKSpriteNode)
            else { fatalError() }

        netDisplay = NetDisplay(
            arkon: sprite, fullNeuronsPortal: np, halfNeuronsPortal: hp, layers: net!.layers
        )

        netDisplay!.display()
    }
}

extension Spawn {

    func abandonNewborn() {
        guard let st = meTheParent, let dp = st.dispatch, let sprite = st.sprite
            else { return }

        func a() {
            let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)
            sprite.run(rotate, completion: b)
        }

        func b() {
            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)
            st.metabolism.fatReserves.level = 0

            assert(st.sprite === st.gridCell.sprite)
            dp.metabolize()
        }

        a()
    }

    func buildArkon(_ onComplete: @escaping () -> Void) {

        func a() {
            SceneDispatch.schedule { [unowned self] in
                Debug.log(level: 102) { "buildArkon/a" }
                self.buildSprites()
                b()
            }
        }

        func b() { self.buildGuts { self.net = $0; c() } }

        func c() {
            SceneDispatch.schedule { [unowned self] in
                Debug.log(level: 102) { "buildArkon/c" }
                guard let sprite = self.thorax else { fatalError() }
                self.buildNetDisplay(sprite)
                onComplete()
            }
        }

        a()
    }

    private func buildSprites() {
        assert(Display.displayCycle == .updateStarted)

        self.nose = SpriteFactory.shared.nosesPool.makeSprite(embryoName)
        self.thorax = SpriteFactory.shared.arkonsPool.makeSprite(embryoName)

        guard let thorax = self.thorax else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let engagerKey = self.engagerKey else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 0.5
        nose.setScale(Arkonia.noseScaleFactor)
        nose.zPosition = 6

        thorax.addChild(self.nose!)
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
        Grid.serialQueue.async(execute: spawn.launchNewborn)
    }
}

extension Spawn {
    func launchNewborn() {
        let newborn = Stepper(self, needsNewDispatch: true)
        assert(newborn.sprite.parent == nil)
        newborn.parentStepper = self.meTheParent
        newborn.dispatch.scratch.stepper = newborn
        newborn.sprite?.color = .yellow
        newborn.nose?.color = .white

        guard let ek = engagerKey else { fatalError() }

        assert(newborn.name == newborn.sprite.name)
        assert((thorax?.name ?? "foo") == newborn.sprite.name)

        Debug.log(level: 115) { "pre-setContents at \(ek.gridPosition), \(ek.contents), \(six(ek.sprite?.name)), \(six(ek.ownerName))" }
        assert(ek.contents != .arkon)
        ek.gridCell?.setContents(to: .arkon, newSprite: newborn.sprite)
        Debug.log(level: 115) { "post-setContents at \(ek.gridPosition), \(ek.contents), \(six(ek.sprite?.name)), \(six(ek.ownerName)) -- \(newborn.gridCell?.gridPosition ?? AKPoint.zero)" }
        newborn.gridCell = ek.gridCell
        Debug.log(level: 104) { "setContents from launchNewborn at \(ek.gridPosition)" }
        Debug.log(level: 109) { "set5 newborn \(six(newborn.name)), parent \(six(self.meTheParent?.name))" }
        self.launchB(ek, newborn)
    }

    private func launchB(_ ek: HotKey, _ newborn: Stepper) {
        Debug.log(level: 115) {
            "launchB parent = \(six(scratch?.stepper?.name))"
            + " should be == \(six(scratch?.stepper?.gridCell.sprite?.name))"
            + " (\(six(scratch?.stepper?.sprite?.getKeyField(.uuid) as? String)))"
            + "; newborn is \(six(newborn.name))"
            + " (\(six(newborn.sprite?.getKeyField(.uuid) as? String)))"
            + " ek \(six(ek.sprite?.name)) \(six(ek.ownerName))"
        }

        ek.sprite?.name = newborn.name
        ek.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: newborn.sprite)

        abandonNewborn()

        guard let ndp = newborn.dispatch else { fatalError() }

        Debug.log(level: 117) { "ndp.scratch.engagerKey = \(ndp.scratch.engagerKey?.gridPosition ?? AKPoint.zero), owner = \(six(ndp.scratch.engagerKey?.ownerName)), tenant = \(six(ndp.scratch.engagerKey?.sprite?.name))" }
        ndp.scratch.engagerKey = ek

        SceneDispatch.schedule {
            Debug.log(level: 105) { "launchB" }

            SpriteFactory.shared.arkonsPool.attachSprite(newborn.sprite)

            let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
            newborn.sprite.run(rotate)

            self.tempStrongReference = nil  // Now the sprite has the only strong ref

            ndp.disengage()
        }
    }
}

extension Spawn {
    func postponeSpawn() {
        guard let st = meTheParent, let dp = st.dispatch else { fatalError() }

        let failedSpawnCost = Arkonia.maxMannaEnergyContentInJoules
        st.metabolism.withdrawFromSpawn(failedSpawnCost)

        st.nose.color = .green
        assert(st.sprite === st.gridCell.sprite)
        dp.metabolize()
    }
}
