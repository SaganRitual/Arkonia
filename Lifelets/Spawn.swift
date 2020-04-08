import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    weak var scratch: Scratchpad?

    var callAgain = false
    var engagerKeyForNewborn: GridCell?
    var embryoName = ArkonName.embryo
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

    func launch() { Grid.arkonsPlaneQueue.async { self.spawn(.arkonsPlane) } }
}

extension Spawn {
    func spawn(_ catchDumbMistakes: DispatchQueueID) {
        func a() {
            embryoName = ArkonName.makeName()

            if meTheParent == nil {
                engagerKeyForNewborn = GridCell.lockRandomEmptyCell(
                    ownerName: embryoName, catchDumbMistakes
                )
            } else {
                engagerKeyForNewborn = scratch!.senseGrid!.setupBirthingCell(for: embryoName)
            }

            if engagerKeyForNewborn == nil {
                Debug.log(level: 169) { "Spawn4 \(six(embryoName)) no available cell; postpone spawn" }
                postponeSpawn()
                return
            }

            meTheParent?.nose.color = .yellow
            buildArkon(b)
        }

        func b() {
            WorkItems.registerBirth(myName: embryoName, myParent: meTheParent, myNet: net) {
                self.fishDay = $0
                self.launchNewborn()
            }
        }

        a()
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

    func abandonNewborn(_ catchDumbMistakes: DispatchQueueID) {
        guard let stepper = meTheParent, let dispatch = stepper.dispatch, let sprite = stepper.sprite
            else { return }

        // We're not going to move until the next cycle; unload the
        // cells we locked when we engaged
        scratch?.senseGrid?.reset(catchDumbMistakes)

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
        guard let engagerKey = self.engagerKeyForNewborn else { fatalError() }

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

extension Spawn {
    // Testing launchNewborn: 158539682 and climbing
    func launchNewborn(_ spawn: Spawn) {
        Grid.arkonsPlaneQueue.async(execute: launchNewborn)
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
        Grid.arkonsPlaneQueue.async { self.launchB(newborn, .arkonsPlane) }
    }

    private func launchB(_ newborn: Stepper, _ catchDumbMistakes: DispatchQueueID) {
        guard let engagerKey = self.engagerKeyForNewborn else { fatalError() }

        newborn.gridCell = engagerKey
        self.engagerKeyForNewborn = nil

        engagerKey.stepper = newborn

        // Name should be set up in the beginning spawn step
        assert(engagerKey.ownerName == newborn.name)

        Stepper.attachStepper(newborn, to: newborn.sprite)

        abandonNewborn(catchDumbMistakes)

        guard let ndp = newborn.dispatch else { fatalError() }

        ndp.scratch.engagerKey = engagerKey
        ndp.scratch.isSpawning = true

        SceneDispatch.shared.schedule { [unowned self] in // Catch dumb mistakes
            Debug.log(level: 168) {
                "launchB for \(six(self.meTheParent?.name)).\(newborn.name)" +
                " -> \(six(self.meTheParent?.gridCell)).\(newborn.gridCell!)" +
                " \(six(self.meTheParent?.gridCell.ownerName))/\(engagerKey.ownerName)"
            }

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
