import SpriteKit

class ArkonEmbryo: GridPlantableArkon {
    var arkonBuilder: ArkonBuilder?
    var birthingCell: GridCell?
    var fishday: Fishday?
    var metabolism: Metabolism?
    var name: ArkonName?
    var net: Net?
    var netDisplay: NetDisplay?
    var newborn: Stepper?
    var noseSprite: SKSpriteNode?
    var parentArkon: Stepper?
    var sensorPad: SensorPad?
    var thoraxSprite: SKSpriteNode?
    var toothSprite: SKSpriteNode?

    init(_ parentArkon: Stepper?, _ birthingCell: GridCell) {
        self.arkonBuilder = ArkonBuilder(embryo: self)
        self.birthingCell = birthingCell
        self.parentArkon = parentArkon
    }

    func beginLife(_ onOffspringReadyToSeparate: (() -> Void)?) {
        buildArkon(onOffspringReadyToSeparate)
    }
}

extension ArkonEmbryo {
    func buildArkon(_ onOffspringReadyToSeparate: (() -> Void)?) {
        func buildArkon_a() { MainDispatchQueue.async(execute: buildArkon_A) }
        func buildArkon_A() { arkonBuilder!.buildGuts(buildArkon_B) }

        func buildArkon_B() { SceneDispatch.shared.schedule(buildArkon_C) }
        func buildArkon_C() { arkonBuilder!.buildSprites(buildArkon_D) }

        func buildArkon_D() { SceneDispatch.shared.schedule(buildArkon_E) }
        func buildArkon_E() { arkonBuilder!.setupNetDisplay(buildArkon_F) }

        func buildArkon_F() { Census.dispatchQueue.async(execute: buildArkon_G) }
        func buildArkon_G() { registerBirth { self.fishday = $0; buildArkon_H() } }

        func buildArkon_H() { MainDispatchQueue.async(execute: buildArkon_I) }
        func buildArkon_I() { self.launch(onOffspringReadyToSeparate) }

        Debug.log(level: 209) { "buildArkon" }
        buildArkon_a()
    }

    func launch(_ onOffspringReadyToSeparate: (() -> Void)?) {
        if let oof = onOffspringReadyToSeparate {
            MainDispatchQueue.async(execute: oof)
        }

        self.newborn = Stepper(self)
        let takeLock = parentArkon != nil

        func launch_A() { Grid.attachArkonToGrid(newborn!, launch_B) }
        func launch_B() { SceneDispatch.shared.schedule(launch_C) }

        func launch_C() {
            SpriteFactory.shared.arkonsPool.attachSprite(newborn!.thorax)

            let rotate = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
            newborn!.thorax.run(rotate, completion: newborn!.tickLife)
        }

        launch_A()
    }

    func registerBirth(_ onComplete: @escaping (Fishday) -> Void) {
        Census.registerBirth(myParent: parentArkon, myNet: net!, onComplete)
    }
}
