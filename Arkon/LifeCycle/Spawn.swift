import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryo: ArkonEmbryo
    let parentArkon: Stepper?

    init(_ parentArkon: Stepper?) {
        self.embryo = ArkonEmbryo(parentArkon)
        self.parentArkon = parentArkon
    }

    func launch() { spawn() }
}

extension Spawn {
    private func spawn() {
        embryo.buildGuts(spawn_B)
    }

    private func spawn_B() {
        SceneDispatch.shared.schedule {
            self.embryo.buildSprites()
            self.spawn_C()
        }
    }

    private func spawn_C() {
        SceneDispatch.shared.schedule {
            self.setupNetDisplay()
            self.spawn_D()
        }
    }

    private func spawn_D() {
        Census.dispatchQueue.async {
            self.embryo.registerBirth()
            self.spawn_E()
        }
    }

    private func spawn_E() {
        MainDispatchQueue.sync {
            self.separateParentFromOffspring()
        }
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

    private func separateParentFromOffspring() {
        // abandonParent() has some work to do even for arkons that come from
        // nowhere, without a parent -- note that the embryo goes off here and
        // becomes a legit arkon with its own dispatch
        embryo.abandonParent()

        // If I'm an arkon giving birth to another arkon, resume my
        // normal life cycle
        if parentArkon != nil { abandonNewborn() }
    }

    private func setupNetDisplay() {
        // If the drone has a NetDisplay object attached, set it up to draw
        // our layer structure on the hud
        guard let ud = embryo.thoraxSprite!.userData,
              let np = (ud[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
              let hp = (ud[SpriteUserDataKey.netHalfNeuronsPortal] as? SKSpriteNode)
            else { return }

        embryo.netDisplay = NetDisplay(
            arkon: embryo.thoraxSprite!,
            fullNeuronsPortal: np, halfNeuronsPortal: hp,
            layerDescriptors: embryo.net!.netStructure.layerDescriptors
        )

        embryo.netDisplay!.display()
    }
}
