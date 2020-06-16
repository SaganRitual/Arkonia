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
        MainDispatchQueue.async(execute: nextStep)
    }

    // No parent; that means the new arkon is coming into the world from
    // nothing, like Oprah Winfrey, or the white Oprah, Chuck Norris. Find
    // a random place in the ooze. Unlike normal births (the kind that have a
    // parent), the self-creating arkon might choose a cell that someone already
    // has locked, in which case it will have to get in line for the cell
    private func spawn_C() {
        let cellIx = Ingrid.randomCellIndex()
        let landingPadCCells = 1

        let es = SensorPadMapper(
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
            parentArkon.thorax!.run(rotate, completion: b)
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
    private func launchNewborn_A() { MainDispatchQueue.async(execute: launchNewborn_B) }

    private func launchNewborn_B() {
        let newborn = Stepper(embryo)

        embryo.placeNewbornOnGrid(newborn)

        SceneDispatch.shared.schedule { self.launchNewborn_C(newborn) }
    }

    private func launchNewborn_C(_ newborn: Stepper) {
        SpriteFactory.shared.arkonsPool.attachSprite(newborn.thorax)

        let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
        newborn.thorax.run(rotate)

        // Newborn goes onto its own dispatch thingy here
        Ingrid.shared.disengageSensorPad(embryo.landingPad!, padCCells: 1)
            { newborn.dispatch!.engageGrid() }

        // If I'm an arkon giving birth to another arkon, resume my
        // normal life cycle
        if embryo.parentArkon != nil { abandonNewborn() }
    }
}
