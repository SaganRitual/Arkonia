import SpriteKit

class Stepper {
    let allowSpawning = true
    private var birthday = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var fishNumber = 0
    weak var gridCell: GridCell!
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
    var sprite: SKSpriteNode!

    init(_ embryo: Larva, needsNewDispatch: Bool = false) {
        self.birthday = embryo.birthday
        self.fishNumber = embryo.fishNumber
        self.gridCell = embryo.cellConnector?.cell
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.sprite = embryo.sprite

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    deinit {
        netDisplay = nil

        Log.L.write("stepper deinit \(six(name))", level: 31)

        World.stats.decrementPopulation(birthday)
    }

    func getAge(_ currentTime: Int) -> Int { return currentTime - self.birthday }
}

extension Stepper {
    func canSpawn() -> Bool {
        return metabolism.spawnReserves.level > getSpawnCost()
    }

    func getSpawnCost() -> CGFloat {
        let entropy: CGFloat = -0.1

        let spawnCost = allowSpawning ?
            EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy) :
            CGFloat.infinity

        return spawnCost
    }
}

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = stepper
        if sprite.userData?["UUID"] == nil { sprite.userData!["UUID"] = UUID().uuidString }
        sprite.name = stepper.name
        Log.L.write("attachStepper \(six(stepper.name)), \(six(sprite.name))", level: 0)
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        Log.L.write("detachStepper \(six(stepper.name)) from sprite \(six(sprite.name))", level: 32)
        if sprite.userData![SpriteUserDataKey.stepper] == nil { fatalError() }
//        stepper.dispatch.scratch.resetGridConnector()
        sprite.userData![SpriteUserDataKey.stepper] = nil
    }
}
