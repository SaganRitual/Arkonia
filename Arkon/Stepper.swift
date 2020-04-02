import SpriteKit

class Stepper {
    var cOffspring = 0
    var dispatch: Dispatch!
    weak var gridCell: GridCell!
    var isTurnabouted: Bool = false
    var metabolism: Metabolism!
    let name: ArkonName
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
    }

    deinit {
        Debug.log(level: 155) { "deinit \(name) \(net.layers.count) layers \(net.cNeurons) neurons" }
    }
}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let spawnCost = Arkonia.allowSpawning ?
            Arkonia.spawnReservesCapacity * 0.95 : CGFloat.infinity

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
        // Some of the drones get their userData set up for the net display,
        // the rest of them we set up here
        if sprite.userData == nil { sprite.userData = [:] }

        // We save the stepper in the userdata of the sprite, but only as
        // a centralized strong reference to the stepper. We don't use it,
        // because retrieving it from the dictionary is way too slow
        sprite.userData!["stepper"] = stepper
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        // See notes in attachStepper
        sprite.userData!["stepper"] = nil
		sprite.name = nil
    }
}
