import SpriteKit

final class Spawn: DispatchableProtocol {
    var dispatch: Dispatch! { willSet { fatalError() } }

    var embryo: ArkonEmbryo
    let parentArkon: Stepper?

    init(_ parentArkon: Stepper?) {
        self.embryo = ArkonEmbryo(parentArkon)
        self.parentArkon = parentArkon
    }

    deinit {
        print("here")
    }

    func launch() { spawn() }
}

extension Spawn {
    private func spawn() {
        if let p = parentArkon { Debug.debugColor(p, .blue, .purple) }

        Debug.log(level: 205) { "spawn start, parent is \(six(parentArkon?.name))" }

        embryo.buildGuts(spawn_B)
    }

    private func spawn_B() {
        SceneDispatch.shared.schedule {
            self.embryo.buildSprites()
            if Arkonia.debugGrid { MainDispatchQueue.asyncAfter(deadline: .now() + 1) { self.spawn_C() } }
            else { self.spawn_C() }
        }
    }

    private func spawn_C() {
        SceneDispatch.shared.schedule {
            self.setupNetDisplay()
            if Arkonia.debugGrid { MainDispatchQueue.asyncAfter(deadline: .now() + 1) { self.spawn_D() } }
            else { self.spawn_D() }
        }
    }

    private func spawn_D() {
        Census.dispatchQueue.async {
            Debug.log(level: 205) { "spawn_D, parent is \(six(self.parentArkon?.name))" }

            self.embryo.registerBirth()
            if Arkonia.debugGrid { MainDispatchQueue.asyncAfter(deadline: .now() + 1) { self.spawn_E() } }
            else { self.spawn_E() }
        }
    }

    private func spawn_E() {
        if Arkonia.debugGrid { MainDispatchQueue.asyncAfter(deadline: .now() + 1) { self.abandonNewborn() } }
        else { MainDispatchQueue.async { self.abandonNewborn() } }
    }
}

extension Spawn {
    func abandonNewborn() {
        Debug.log(level: 205) { "abandonNewborn.0" }

        func a() {
            Debug.log(level: 205) { "abandonNewborn.2" }
            if let p = parentArkon {
                let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)
                p.thorax.run(rotate, completion: b)
            }

            b()
        }

        func b() {
            let birthingCell: GridCellConnector
            if let bc = parentArkon?.detachBirthingCellForNewborn() { birthingCell = bc }
            else { birthingCell = Ingrid.randomCell() }

            embryo.detachFromParent(birthingCell) // Off you go, don't talk to strangers

            parentArkon?.metabolism.detachOffspring()
            parentArkon?.dispatch.disengageGrid()
        }

        Debug.log(level: 205) { "abandonNewborn.1" }
        a()
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
