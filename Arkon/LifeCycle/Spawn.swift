import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryo: ArkonEmbryo
    let parentArkon: Stepper?

    init(_ parentArkon: Stepper?) {
        self.embryo = ArkonEmbryo(parentArkon)
        self.parentArkon = parentArkon
    }

    func launch() { spawn_A() }
}

extension Spawn {
    private func spawn_A() {
        Census.dispatchQueue.async(execute: spawn_B_registerBirth)
    }

    private func spawn_B_registerBirth() {
        embryo.registerBirth()

        SceneDispatch.shared.schedule { [unowned self] in
            // Calls back on the main dispatch queue
            self.embryo.buildSprites(self.spawn_C_buildGuts)
        }
    }

    private func spawn_C_buildGuts() {
        embryo.buildGuts(spawn_D_buildNetDisplay)
    }

    private func spawn_D_buildNetDisplay(_ net: Net) {
        SceneDispatch.shared.schedule { [unowned self] in
            self.buildNetDisplay(self.embryo.thoraxSprite!)
            MainDispatchQueue.async(execute: self.spawn_E_engageGrid)
        }
    }

    private func spawn_E_engageGrid() {
        let birthingCell = (parentArkon == nil) ?
            IngridCellDescriptor(Ingrid.randomCell()) : embryo.getBirthingCell()

        embryo.sensorPad!.engageBirthCell(
            center: birthingCell.absoluteIndex, embryo.launch
        )

        // If I'm an arkon giving birth to another arkon, resume my
        // normal life cycle
        if parentArkon != nil { abandonNewborn() }
    }
}

extension Spawn {
    func abandonNewborn() {
        guard let parentArkon = self.parentArkon, let dispatch = parentArkon.dispatch
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
