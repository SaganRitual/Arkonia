import SpriteKit

class Stepper {
    let allowSpawning = true
    var birthday = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var fishNumber = 0
    weak var gridCell: GridCell!
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
    var sprite: SKSpriteNode!

    init(_ embryo: WangkhiEmbryo, needsNewDispatch: Bool = false) {
        self.birthday = embryo.birthday
        self.fishNumber = embryo.fishNumber
        self.gridCell = embryo.gridCell
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.sprite = embryo.sprite

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    deinit {
//        Log.L.write("stepper deinit", six(name))
        World.stats.decrementPopulation(nil)
    }

}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let entropy: CGFloat = 0.1

        let spawnCost = allowSpawning ?
            EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy) :
            CGFloat.infinity

        return spawnCost
    }
}

func spriteAKName(_ sprite: SKSpriteNode) -> String {
    guard let userData = sprite.userData else { fatalError() }
    guard let entry = userData["UUID"] as? String else { fatalError() }
    return entry
}

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = stepper
        if sprite.userData?["UUID"] == nil { sprite.userData!["UUID"] = UUID().uuidString }
        sprite.name = stepper.name
        Log.L.write("attachStepper \(six(stepper.name)), \(six(spriteAKName(sprite)))")
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        Log.L.write("detachStepper \(six(stepper.name)) from sprite \(spriteAKName(sprite))")
        if sprite.userData![SpriteUserDataKey.stepper] == nil { fatalError() }
        sprite.userData![SpriteUserDataKey.stepper] = nil
    }
}
