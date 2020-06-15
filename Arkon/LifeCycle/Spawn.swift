import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryo: ArkonEmbryo

    init(_ parentArkon: Stepper?) {
        self.embryo = ArkonEmbryo(parentArkon)
    }

    func launch() { spawn_A() }
}

extension Spawn {
    private func spawn_A() {
        Census.dispatchQueue.async(execute: spawn_B)
    }

    private func spawn_B() {
        embryo.name = ArkonName.makeName()
        let nextStep = (self.embryo.parentArkon == nil) ? spawn_C : spawn_D
        Dispatch.dispatchQueue.async(execute: nextStep)
    }

    // No parent; that means I'm a disembodied something-or-other bringing
    // an arkon into existence from nothing. Find a random home for it.
    // Note: if the desired cell isn't available, the engager function
    // will wait for it and send us on our way when it is available. First
    // come is first served as locked cells become available
    private func spawn_C() {
        let cellIx = Ingrid.randomCellIndex()
        let landingPadCCells = 1

        let es = EngagerSpec(
            landingPadCCells, cellIx, embryo.landingPad!, spawn_D
        )

        Ingrid.shared.engageSensorPad(es)   // The es points us to the next step
    }

    private func spawn_D() { buildArkon(spawn_E) }

    private func spawn_E() {
        Census.registerBirth(
            myName: embryo.name!, myParent: embryo.parentArkon, myNet: embryo.net!
        ) {
            self.embryo.fishDay = $0
            self.launchNewborn_A()
        }
    }
}

extension Spawn {
    func buildGuts(_ onComplete: @escaping (Net) -> Void) {
        let nn = embryo.parentArkon?.net

        Net.makeNet(nn?.netStructure, nn?.pBiases, nn?.pWeights) { newNet in
            self.embryo.metabolism = Metabolism(cNeurons: newNet.netStructure.cNeurons)
            onComplete(newNet)
        }
    }
}

extension Spawn {
    func buildNetDisplay(_ sprite: SKSpriteNode) {
        guard let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode)
            else { return }

        let hp = (sprite.userData?[SpriteUserDataKey.netHalfNeuronsPortal] as? SKSpriteNode)!

        embryo.netDisplay = NetDisplay(
            arkon: sprite, fullNeuronsPortal: np, halfNeuronsPortal: hp,
            layerDescriptors: embryo.net!.netStructure.layerDescriptors
        )

        embryo.netDisplay!.display()
    }
}

extension Spawn {
    func abandonNewborn() {
        guard let parentArkon = embryo.parentArkon, let dispatch = parentArkon.dispatch
            else { return }

        func a() {
            let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)
            embryo.thoraxSprite!.run(rotate, completion: b)
        }

        func b() {
            parentArkon.metabolism.detachSpawnEmbryo()
            dispatch.disengageGrid()
        }

        a()
    }

    func buildArkon(_ onComplete: @escaping () -> Void) {

        func a() {
            SceneDispatch.shared.schedule { [unowned self] in
                Debug.log(level: 102) { "buildArkon/a" }
                self.embryo.buildSprites()
                b()
            }
        }

        func b() { self.buildGuts { self.embryo.net = $0; c() } }

        func c() {
            SceneDispatch.shared.schedule { [unowned self] in
                self.buildNetDisplay(self.embryo.thoraxSprite!)
                onComplete()
            }
        }

        a()
    }
}

extension Spawn {
    private func launchNewborn_A() { Dispatch.dispatchQueue.async(execute: launchNewborn_B) }

    private func launchNewborn_B() {
        let newborn = Stepper(embryo)

        Debug.log(level: 200) { "launchNewborn_B bc = \(embryo.birthingCell.absoluteIndex)" }

        embryo.placeNewbornOnGrid(newborn)

        abandonNewborn()

        SceneDispatch.shared.schedule { self.launchNewborn_C(newborn) }
    }

    private func launchNewborn_C(_ newborn: Stepper) {
        SpriteFactory.shared.arkonsPool.attachSprite(newborn.thorax)

        let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
        newborn.thorax.run(rotate)

        newborn.dispatch!.disengageGrid()
    }
}
