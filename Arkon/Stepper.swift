import SpriteKit

class Stepper {
    var cOffspring = 0
    var dispatch: Dispatch!
    weak var gridCell: GridCell!
    var isTurnabouted: Bool = false
    var metabolism: Metabolism!
    let name: String
    var net: Net!
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode!
    var parentBiases: [Double]?
    var parentLayers: [Int]?
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShiftOffset = AKPoint.zero
    weak var sprite: SKSpriteNode!

    init(_ embryo: Spawn, needsNewDispatch: Bool = false) {
        self.gridCell = embryo.engagerKey!.gridCell
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.sprite = embryo.thorax

        if needsNewDispatch { self.dispatch = Dispatch(self) }

        let isLocked = embryo.engagerKey!.gridCell?.isLocked
        let lockOwner = embryo.engagerKey!.gridCell?.ownerName ?? "no owner"
        let occupiedBy = embryo.engagerKey!.gridCell?.sprite?.name ?? "no one"
        let isLockedString = isLocked == nil ? "nothing" : (isLocked! ? "already locked" : "not yet locked")
        Debug.log(level: 109) {
            "set1 \(six(embryo.embryoName))"
            + " isLocked \(isLockedString) by \(six(lockOwner))"
            + " occupied by \(six(occupiedBy))"
            + ", parent is \(six(parentStepper?.name))"
        }
    }

    deinit {
        Debug.log(level: 146) { "deinit \(name)" }
    }
}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let spawnCost = Arkonia.allowSpawning ?
            EnergyReserve.spawnReservesCapacity * 0.95 : CGFloat.infinity

        Debug.log(level: 95) {
            if metabolism.spawnReserves.level <= 0 { return nil }

            let sc = String(format: "%3.3f", spawnCost)
            let sr = String(format: "%3.3f", metabolism.spawnReserves.level)
            let sf = String(format: "%3.3f%%", metabolism.spawnEnergyFullness * 100)
            return "spawnCost(\(six(name))) = \(sc); spawnReserves at \(sr) (\(sf))"
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
