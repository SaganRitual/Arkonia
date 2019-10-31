import SpriteKit

class Stepper {
    let allowSpawning = true
    var birthday = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var fishNumber = 0
    weak var gridlet: Gridlet!
    var previousGridletContents = Gridlet.Contents.nothing
    var metabolism: Metabolism!
    let name = UUID().uuidString
    var net: Net!
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode!
    var oldGridlet: Gridlet?
    var parentActivator: ((_: Double) -> Double)?
    var parentBiases: [Double]?
    var parentLayers: [Int]?
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShift = AKPoint.zero
    var sprite: SKSpriteNode!

    init(_ parentStepper: Stepper? = nil) {
        self.parentStepper = parentStepper
        self.parentActivator = parentStepper?.net?.activatorFunction
        self.parentBiases = parentStepper?.net?.biases
        self.parentLayers = parentStepper?.net?.layers
        self.parentWeights = parentStepper?.net?.weights

        dispatch = Dispatch(self)
    }

    init(_ embryo: WangkhiEmbryo, needsNewDispatch: Bool = false) {
        self.birthday = embryo.birthday
        self.fishNumber = embryo.fishNumber
        self.gridlet = embryo.gridlet
        self.metabolism = embryo.metabolism
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.nose
        self.sprite = embryo.sprite

        if needsNewDispatch {
            self.dispatch = Dispatch(self)
            self.dispatch.stepper = self
        }
    }

    deinit {
//        print("d1")
        let gridlet = self.gridlet!
        Grid.lock({ () -> [Void]? in
            gridlet.contents = .nothing
            gridlet.sprite = nil
            gridlet.gridletIsEngaged = false
//            print("d2 \(gridlet.gridPosition)")
            return nil
        })

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

extension Stepper {
    static func attachStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = stepper
    }

    static func getStepper(from sprite: SKSpriteNode, require: Bool = true) -> Stepper? {
        guard let dictionary = sprite.userData else { fatalError() }

        guard let entry = dictionary[SpriteUserDataKey.stepper] else {
            if require { fatalError() } else { return nil }
        }

        guard let stepper = entry as? Stepper else {
            if require { fatalError() } else { return nil }
        }

        return stepper
    }

    static func releaseStepper(_ stepper: Stepper, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.stepper] = nil
    }
}
