import SpriteKit

class ArkonEmbryo {
    var arkonBuilder: ArkonBuilder?
    var fishday: Fishday?
    var metabolism: Metabolism?
    var name: ArkonName?
    var net: Net?
    var netStructure: NetStructure?
    var newborn: Stepper?
    var noseSprite: SKSpriteNode?
    weak var parentArkon: Stepper?
    var sensorPad: SensorPad?
    var spindle: Spindle?
    var spindleTarget: GridCell?
    let spindleTargetIsPreLocked: Bool
    var thoraxSprite: SKSpriteNode?
    var toothSprite: SKSpriteNode?

    init(
        _ parentArkon: Stepper?, _ spindleTarget: GridCell,
        spindleTargetIsPreLocked: Bool
    ) {
        self.spindleTargetIsPreLocked = spindleTargetIsPreLocked
        self.arkonBuilder = ArkonBuilder(embryo: self)
        self.spindleTarget = spindleTarget
        self.parentArkon = parentArkon
    }

    func beginLife(_ onOffspringReadyToSeparate: (() -> Void)?) {
        buildArkon(onOffspringReadyToSeparate)
    }
}

extension ArkonEmbryo {
    func buildArkon(_ onOffspringReadyToSeparate: (() -> Void)?) {

        Debug.log(level: 209) { "buildArkon" }

        var worldClock = 0
        var cNeurons = 0

        Clock.dispatchQueue.async { buildArkon_0() }

        func buildArkon_0() { worldClock = Int(Clock.shared.worldClock); buildArkon_1() }

        func buildArkon_1() { mainDispatch(buildArkon_A) }

        func buildArkon_A() { buildNetStructure(); buildArkon_B() }

        func buildArkon_B() { Census.dispatchQueue.async(execute: buildArkon_C) }
        func buildArkon_C() {
            cNeurons = Census.shared.registerBirth(netStructure!, parentArkon)
            self.fishday = Fishday(currentTime: worldClock, cNeurons: cNeurons)
            buildArkon_D()
        }

        func buildArkon_D() { mainDispatch(buildArkon_E) }
        func buildArkon_E() { arkonBuilder!.buildGuts(buildArkon_F) }

        func buildArkon_F() { SceneDispatch.shared.schedule("buildArkon_F", buildArkon_G) }
        func buildArkon_G() { arkonBuilder!.buildSprites(buildArkon_J) }

        func buildArkon_J() { mainDispatch(buildArkon_K) }
        func buildArkon_K() { self.launch(onOffspringReadyToSeparate) }
    }

    func buildNetStructure() {
        self.netStructure = NetStructure(
            parentArkon?.net.netStructure.cSenseRings,
            parentArkon?.net.netStructure.layerDescriptors
        )
    }

    func launch(_ onOffspringReadyToSeparate: (() -> Void)?) {
        self.newborn = Stepper(self)
        self.newborn!.spindle.postInit(self.newborn!)

        if let oof = onOffspringReadyToSeparate {
            Debug.log(level: 212) { "separate \(self.newborn!.name) from parent" }
            mainDispatch(oof)
        }

        Debug.log(level: 214) {
            "launch newborn \(self.newborn!.name) child of \(AKName(parentArkon?.name))"
            + " at spindle target \(self.spindleTarget!.properties)"
        }

        func launch_A() { SceneDispatch.shared.schedule("embryo launch_A", launch_B) }

        func launch_B() {
            SpriteFactory.shared.arkonsPool.attachSprite(newborn!.thorax)

            let birthDance = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 0.5)
            newborn!.thorax.run(birthDance)

//            let deathDance = SKAction.rotate(byAngle: -2 * CGFloat.tau, duration: 1)
//            let forever = SKAction.repeatForever(deathDance)
//            newborn!.tooth.run(forever)

            // Parent will have relinquished its hold on the live connection
            newborn!.spindle.attachToGrid(iHaveTheLiveConnection: spindleTargetIsPreLocked, launch_C)
        }

        func launch_C() {
            // Should do this long before, during the build process when we have
            // the census lock already, but it's ugly and I don't feel like
            // fixing it right now
            Census.dispatchQueue.async {
                Census.shared.censusAgent.insert(self.newborn!)
                launch_D()
            }
        }

        func launch_D() {
            // Away we go. If I'm supernatural, I might have to wait for my
            // birth cell to become available, if someone else is in it, or
            // looking at it. If I'm a natural birth, an offspring from an
            // arkon, the cell is locked and waiting just for me
            newborn!.spindle.sensorPad.engageSensors(newborn!.tickLife)
        }

        launch_A()
    }
}
