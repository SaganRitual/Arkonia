import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryoName: ArkonName?
    var fishDay = Fishday(birthday: 0, cNeurons: 0, fishNumber: 0)
    let landingPad: UnsafeMutablePointer<IngridCellDescriptor>?
    var metabolism: Metabolism?
    let meTheParent: Stepper?
    var net: Net?
    var netDisplay: NetDisplay?
    var newborn: Stepper?
    var newbornNose: SKSpriteNode?
    var newbornThorax: SKSpriteNode?
    var newbornTooth: SKSpriteNode?

    init(_ stepper: Stepper?) {
        self.meTheParent = stepper

        if stepper != nil { self.landingPad = nil; return }

        self.landingPad = .allocate(capacity: 1)
        self.landingPad!.initialize(to: IngridCellDescriptor())
    }

    func launch() { spawn_A() }
}

extension Spawn {
    private func spawn_A() {
        Census.dispatchQueue.async(execute: spawn_B)
    }

    private func spawn_B() {
        self.embryoName = ArkonName.makeName()
        Dispatch.dispatchQueue.async(execute: spawn_C)
    }

    private func spawn_C() {
        // No parent; that means I'm a disembodied something-or-other bringing
        // an arkon into existence from nothing. Find a random home for it.
        // Note: if the desired cell isn't available, the engager function
        // will wait for it and send us on our way when it is available. First
        // come is first served as locked cells become available
        if meTheParent == nil {
            let cellIx = Ingrid.randomCellIndex()

            // Ok, it's a landing pad rather than a sensor pad, but it's
            // the same thing internally; we need it for locking the cell
            let es = EngagerSpec(1, cellIx, landingPad!, self.spawn_D)

            Ingrid.shared.engageSensorPad(es)
            return
        }

        spawn_D()   // I'm an arkon making a new arkon
    }

    private func spawn_D() { buildArkon(spawn_E) }

    private func spawn_E() {
        Census.registerBirth(myName: embryoName!, myParent: meTheParent, myNet: net!) {
            self.fishDay = $0
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
        guard let stepper = meTheParent, let dispatch = stepper.dispatch
            else { return }

        let thorax = stepper.thorax

        func a() {
            let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)
            thorax!.run(rotate, completion: b)
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
                let thorax = self.newbornThorax!
                thorax.name = "\(self.embryoName!)"

                self.buildNetDisplay(thorax)
                onComplete()
            }
        }

        a()
    }

    private func buildSprites() {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        self.newbornTooth = SpriteFactory.shared.teethPool.makeSprite(embryoName)
        self.newbornNose = SpriteFactory.shared.nosesPool.makeSprite(embryoName)
        self.newbornThorax = SpriteFactory.shared.arkonsPool.makeSprite(embryoName)

        let thorax = self.newbornThorax!
        let nose = self.newbornNose!
        let tooth = self.newbornTooth!

        tooth.alpha = 1
        tooth.colorBlendFactor = 1
        tooth.color = .red
        tooth.zPosition = 4

        nose.addChild(tooth)
        nose.alpha = 1
        nose.colorBlendFactor = 1
        nose.color = .blue
        nose.setScale(Arkonia.noseScaleFactor)
        nose.zPosition = 3

        // We don't set the arkon's main sprite position here; we set it later,
        // after we have a sensor pad and stuff set up
        thorax.addChild(nose)
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
        newborn.thorax.color = (net?.isCloneOfParent ?? false) ? .green : .white
        newborn.nose?.color = .blue

        let birthingCell =
            self.landingPad?[0] ?? meTheParent!.detachBirthingCellForNewborn()

        placeNewborn(newborn, at: birthingCell)

        abandonNewborn()

        SceneDispatch.shared.schedule {
            SpriteFactory.shared.arkonsPool.attachSprite(newborn.thorax)

            let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
            newborn.thorax.run(rotate)

            newborn.dispatch!.disengageGrid()
        }
    }

    private func placeNewborn(_ newborn: Stepper, at birthingCell: IngridCellDescriptor) {
        newborn.sensorPad[0] = birthingCell
        newborn.thorax.position = birthingCell.coreCell!.scenePosition

        Ingrid.shared.arkons.placeArkon(newborn, atIndex: birthingCell.absoluteIndex)
    }
}
