import SpriteKit

class Stepper {
    var cOffspring = 0
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

        Log.L.write("Stepper \(six(embryo.embryoName))", level: 71)
    }

    deinit {
        dispatch.scratch.engagerKey = nil
        Log.L.write("~Stepper \(six(name))", level: 71)
    }
}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let spawnCost = Arkonia.allowSpawning ?
            EnergyReserve.spawnReservesCapacity * 0.95 : CGFloat.infinity

        let sc = String(format: "%3.3f", spawnCost)
        let sr = String(format: "%3.3f", metabolism.spawnReserves.level)
        let sf = String(format: "%3.3f%%", metabolism.spawnEnergyFullness * 100)
        if metabolism.spawnReserves.level > 0 {
            Log.L.write("spawnCost(\(six(name))) = \(sc); spawnReserves at \(sr) (\(sf))", level: 74)
        }
        return spawnCost
    }
}

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = stepper
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = nil
		sprite.name = nil
    }
}
