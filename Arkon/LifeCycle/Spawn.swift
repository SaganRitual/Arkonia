import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryoName = ArkonName.embryo
    var fishDay = Fishday(birthday: 0, cNeurons: 0, fishNumber: 0)
    let landingPad: UnsafeMutablePointer<IngridCellDescriptor>
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    weak var newborn: Stepper?
    var nose: SKSpriteNode?
    weak var meTheParent: Stepper?
    var thorax: SKSpriteNode?
    var tempStrongReference: Spawn?
    var tooth: SKSpriteNode?

    init(_ stepper: Stepper?) {
        self.meTheParent = stepper

        self.landingPad = .allocate(capacity: 1)
        self.landingPad.initialize(to: IngridCellDescriptor())

        self.tempStrongReference = self
    }

    func launch() { spawn_A() }
}

extension Spawn {
    private func spawn_A() {
        Debug.log(level: 191) { "Spawn.spawn_A" }

        // No parent; that means I'm a disembodied something-or-other bringing
        // an arkon into existence from nothing. Find a random home for it;
        // remember, if the desired cell isn't available, the engager function
        // will wait for it and send us along when it is available
        if meTheParent == nil {
            let cellIx = Ingrid.randomCellIndex()

            // Ok, it's a landing pad rather than a sensor pad, but it's
            // the same thing internally; we need it for locking the cell
            let es = EngagerSpec(
                cCellsInRange: 1, center: cellIx,
                onComplete: spawn_B, pad: self.landingPad
            )

            Ingrid.shared.engageSensorPad(es)
            return
        }

        spawn_B()   // I'm an arkon making a new arkon
    }

    private func spawn_B() { buildArkon(spawn_C) }

    private func spawn_C() {
        Census.registerBirth(myName: embryoName, myParent: meTheParent, myNet: net!) {
            self.fishDay = $0
            self.embryoName = ArkonName.makeName()
            self.launchNewborn_A()
        }
    }
}

extension Spawn {
    func buildGuts(_ onComplete: @escaping (Net) -> Void) {
        Debug.log(level: 121) { "\(six(meTheParent?.name))" }

        let nn = meTheParent?.net

        Net.makeNet(nn?.netStructure, nn?.pBiases, nn?.pWeights) { newNet in
            self.metabolism = Metabolism(cNeurons: newNet.netStructure.cNeurons)
            onComplete(newNet)
        }
    }
}

extension Spawn {
    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        let hp = (sprite.userData?[SpriteUserDataKey.netHalfNeuronsPortal] as? SKSpriteNode)!

        netDisplay = NetDisplay(
            arkon: sprite, fullNeuronsPortal: np, halfNeuronsPortal: hp,
            layerDescriptors: net!.netStructure.layerDescriptors
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
            stepper.metabolism.detachSpawnEmbryo()
            dispatch.disengageGrid()
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
                let sprite = (self.thorax)!
                self.buildNetDisplay(sprite)
                onComplete()
            }
        }

        a()
    }

    private func buildSprites() {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        self.tooth = SpriteFactory.shared.teethPool.makeSprite(embryoName)
        self.nose = SpriteFactory.shared.nosesPool.makeSprite(embryoName)
        self.thorax = SpriteFactory.shared.arkonsPool.makeSprite(embryoName)

        let thorax = self.thorax!
        let nose = self.nose!
        let tooth = self.tooth!

        tooth.alpha = 1
        tooth.colorBlendFactor = 1
        tooth.color = .red
        tooth.zPosition = 4

        nose.addChild(self.tooth!)
        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.color = .blue
        nose.setScale(Arkonia.noseScaleFactor)
        nose.zPosition = 3

        // We don't set the arkon's main sprite position here; we set it later,
        // after we have a sensor pad and stuff set up
        thorax.addChild(self.nose!)
        thorax.setScale(Arkonia.arkonScaleFactor * 1.0 / Arkonia.zoomFactor)
        thorax.colorBlendFactor = 0.5
        thorax.alpha = 1
        thorax.zPosition = 2

        let noseColor: SKColor = (meTheParent == nil) ? .systemBlue : .yellow
        Debug.debugColor(thorax, .blue, nose, noseColor)
    }
}

extension Spawn {
    private func launchNewborn_A() { Dispatch.dispatchQueue.async(execute: launchNewborn_B) }

    private func launchNewborn_B() {
        let newborn = Stepper(self, needsNewDispatch: true)

        newborn.parentStepper = meTheParent
        newborn.sprite?.color = (net?.isCloneOfParent ?? false) ? .green : .white
        newborn.nose?.color = .blue

        let bc: IngridCellDescriptor

        if let p = meTheParent { bc = p.detachRandomCellForNewborn() }
        else                   { bc = self.landingPad[0] }

        newborn.sensorPad[0] = bc
        newborn.sprite.position = bc.cell!.scenePosition

        newborn.ingridCellAbsoluteIndex = bc.absoluteIndex

        Stepper.attachStepper(newborn, to: newborn.sprite)

        abandonNewborn()

        let ndp = newborn.dispatch!

        SceneDispatch.shared.schedule { [unowned self] in // Catch dumb mistakes
            SpriteFactory.shared.arkonsPool.attachSprite(newborn.sprite)

            let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
            newborn.sprite.run(rotate)

            self.tempStrongReference = nil  // Now the sprite has the only strong ref

            ndp.disengageGrid()
        }
    }
}
