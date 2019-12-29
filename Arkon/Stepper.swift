import SpriteKit

class Stepper {
    let allowSpawning = true
    var cOffspring = 0
    var debugFlasher = false
    var dispatch: Dispatch!
    private weak var gridCell_: GridCell?
    var gridCell: GridCell! {
        get { gridCell_ }
        set { gridCell_ = newValue }
    }
    var isTurnabouted: Bool = false
    var metabolism: Metabolism!
    let name: String
    var net: Net!
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode!
    var parentActivator: ((_: Double) -> Double)?
    var parentBiases: [Double]?
    var parentLayers: [Int]?
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShiftOffset = AKPoint.zero
    weak var sprite: SKSpriteNode!

    init(_ embryo: Spawn, needsNewDispatch: Bool = false) {
        self.gridCell_ = embryo.engagerKey!.bell
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.sprite = embryo.thorax

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    deinit {
        netDisplay = nil

        Log.L.write("stepper deinit \(six(name))/\(six(sprite.name))", level: 70)

        Census.shared.registerDeath(name)

        Log.L.write("stepper deinit report \(dispatch.scratch.debugReport)", level: 70)
    }
}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let overhead: CGFloat = 1.5

        let spawnCost = allowSpawning ?
            EnergyReserve.startingEnergyLevel * overhead : CGFloat.infinity

        let sc = String(format: "%3.3f", spawnCost)
        let sr = String(format: "%3.3f", metabolism.spawnReserves.level)
        let sf = String(format: "%3.3f%%", metabolism.spawnEnergyFullness * 100)

        Log.L.write("spawnCost = \(sc); spawnReserves at \(sr) (\(sf))", level: 45)
        return spawnCost
    }
}

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = stepper
        precondition(stepper.name == sprite.name)

        Log.L.write("attachStepper \(six(stepper.name)), \(six(sprite.name))", level: 55)
//        sprite.name = stepper.name
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = nil
    }
}
