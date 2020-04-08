import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var birthplace: GridCell?
    var callAgain = false
    var engagerKey: GridCell?
    let embryoName = ArkonName.makeName()
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

        if let ss = scratch.senseGrid?.cells.firstIndex(where: { ($0 as? GridCell) === self.birthplace }) {
            Debug.log(level: 167) { "wtf? \(scratch.stepper.name) -> \(ss) \(six(scratch.senseGrid?.cells[ss] as? GridCell))" }
            scratch.senseGrid?.cells[ss] = ColdKey(for: self.birthplace!)
        }

        Debug.log(level: 167) {
            return "Spawn: parent \(six(meTheParent?.name))"
                + " at \(String(describing: meTheParent?.gridCell?.gridPosition))"
                + " spawns \(six(embryoName))"
                + " at \(String(describing: birthplace?.gridPosition))"
                + " owner \(six(self.birthplace?.ownerName))"
        }
    }

    func launch() { WorkItems.spawn(self) }
}

extension WorkItems {
    static func spawn(_ spawn: Spawn) {
        var newKey: GridCell?

        Debug.log(level: 167) { "Spawn1 \(six(spawn.embryoName)) at \(six(spawn.birthplace?.gridPosition))" }

        func a() {
            if spawn.birthplace == nil {
                getStartingPosition(spawn.fishDay, spawn.embryoName, spawn.meTheParent) {
                    newKey = $0
                    b()
                }

                return
            }

            newKey = spawn.birthplace
            b()
        }

        func b() {
            if newKey == nil {
                Debug.log(level: 167) { "Spawn4 \(six(spawn.embryoName)) no available cell; postpone spawn" }
                spawn.postponeSpawn()
            } else { c() }
        }

        func c() {
            spawn.engagerKey = newKey
//            spawn.meTheParent?.nose.color = .yellow

            spawn.buildArkon(d)
        }

        func d() {

            registerBirth(myName: spawn.embryoName, myParent: spawn.meTheParent, myNet: spawn.net)
                { spawn.fishDay = $0; e() }
        }

        func e() {
            WorkItems.launchNewborn(spawn)
       }

        a()
    }
}

extension WorkItems {
    static private func getStartingPosition(
        _ fishDay: Fishday, _ embryoName: ArkonName, _ meTheParent: Stepper?, _ onComplete: @escaping (GridCell?) -> Void
    ) {
        Grid.arkonsPlaneQueue.async {
            let key = getStartingPosition(fishDay, embryoName, meTheParent, .arkonsPlane)
            onComplete(key)
        }
    }

    static private func getStartingPosition(
        _ fishDay: Fishday, _ embryoName: ArkonName, _ meTheParent: Stepper?, _ catchDumbMistakes: DispatchQueueID
    ) -> GridCell? {
        guard let parent = meTheParent else {
            return GridCell.lockRandomEmptyCell(
                ownerName: ArkonName.makeName(.aboriginal, fishDay.fishNumber), catchDumbMistakes
            )
        }

        return parent.dispatch.scratch.senseGrid?.cells
            .dropFirst()
            .compactMap({ $0 as? GridCell })
            .filter({ $0.stepper == nil && $0.ownerName == parent.name })
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
typealias OnComplete1p = (GridCell?) -> Void

extension Spawn {
    func buildGuts(_ onComplete: @escaping (Net) -> Void) {
        metabolism = Metabolism()

        Debug.log(level: 121) { "\(six(meTheParent?.name))" }
        Net.makeNet(
            parentBiases: meTheParent?.net.biases.map({ Double($0) }),
            parentWeights: meTheParent?.net.weights.map({ Double($0) }),
            layers: meTheParent?.net.layers
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
        guard let stepper = meTheParent, let dispatch = stepper.dispatch, let sprite = stepper.sprite
            else { return }

        func a() {
            let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)
            sprite.run(rotate, completion: b)
        }

        func b() {
            let spawnCost = stepper.getSpawnCost()
            stepper.metabolism.withdrawFromSpawn(spawnCost)
            stepper.metabolism.fatReserves.level = 0

            dispatch.metabolize()
        }

        a()
    }

    func buildArkon(_ onComplete: @escaping () -> Void) {

        func a() {
            SceneDispatch.shared.schedule { [unowned self] in
                Debug.log(level: 102) { "buildArkon/a" }
                self.buildSprites()
                b()
            }
        }

        func b() { self.buildGuts { self.net = $0; c() } }

        func c() {
            SceneDispatch.shared.schedule { [unowned self] in
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
        nose.zPosition = 3

        thorax.addChild(self.nose!)
        thorax.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        thorax.colorBlendFactor = 0.5
        thorax.position = engagerKey.scenePosition
        thorax.alpha = 1
        thorax.zPosition = 2

        let noseColor: SKColor = (meTheParent == nil) ? .magenta : .yellow
        Debug.debugColor(thorax, .green, nose, noseColor)
    }
}

extension WorkItems {
    // Testing launchNewborn: 158539682 and climbing
    static func launchNewborn(_ spawn: Spawn) {
        Grid.arkonsPlaneQueue.async(execute: spawn.launchNewborn)
    }
}

extension Spawn {
    func launchNewborn() {
        let newborn = Stepper(self, needsNewDispatch: true)
        assert(newborn.sprite.parent == nil)
        newborn.parentStepper = self.meTheParent
        newborn.dispatch.scratch.stepper = newborn
        newborn.sprite?.color = (net?.isCloneOfParent ?? false) ? .green : .white
        newborn.nose?.color = (net?.isCloneOfParent ?? false) ? .green : .white

        // Schedule the second part separately, to avoid holding the grid too long
        // 113533466 and climbing
        Grid.arkonsPlaneQueue.async { self.launchB(newborn) }
    }

    private func launchB(_ newborn: Stepper) {
        guard let gridCell = self.engagerKey else { fatalError() }

        newborn.gridCell = gridCell

        gridCell.stepper = newborn
        gridCell.ownerName = newborn.name

        Stepper.attachStepper(newborn, to: newborn.sprite)

        abandonNewborn()

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = self.engagerKey

        SceneDispatch.shared.schedule { [unowned self] in // Catch dumb mistakes
            Debug.log(level: 167) { "launchB for \(newborn.name) -> \(newborn.gridCell!) \(newborn.gridCell.ownerName)/\(gridCell.ownerName)" }

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
        guard let stepper = meTheParent, let dispatch = stepper.dispatch else { fatalError() }

        let failedSpawnCost = Arkonia.maxMannaEnergyContentInJoules
        stepper.metabolism.withdrawFromSpawn(failedSpawnCost)

        stepper.nose.color = .blue
        dispatch.metabolize()
    }
}
