import SpriteKit

class Stepper {
    typealias OnComplete1 = (Stepper) -> Void
    typealias OnComplete2 = (Stepper, Stepper) -> Void

    let allowSpawning = true
    var arkonFactory: ArkonFactory?
    var birthday: TimeInterval!
    var cOffspring = 0
    var fishNumber = 0
    weak var gridlet: Gridlet!
    var isApoptosizing = false
    var metabolism: Metabolism!
    let name = UUID().uuidString
    var net: Net!
    var netDisplay: NetDisplay?
    var newGridlet: Gridlet?
    var nose: SKSpriteNode!
    var oldGridlet: Gridlet?
    var parentActivator: ((_: Double) -> Double)?
    var parentBiases: [Double]?
    var parentLayers: [Int]?
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShift = AKPoint.zero
    var shifter: Shifter?
    var sprite: SKSpriteNode!

    var bandaid: NewStepper?

    init(_ parentStepper: Stepper? = nil) {
        self.parentStepper = parentStepper
        self.parentActivator = parentStepper?.net?.activatorFunction
        self.parentBiases = parentStepper?.net?.biases
        self.parentLayers = parentStepper?.net?.layers
        self.parentWeights = parentStepper?.net?.weights
    }

    deinit {
        let gridlet = self.gridlet!
        Grid.lock({ () -> [Void]? in
            gridlet.contents = .nothing
            gridlet.sprite = nil
            gridlet.gridletIsEngaged = false
//            print("deinit \(gridlet.gridPosition)")
            return nil
        })
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

    func spawnCommoner() {
        let spawnCost = getSpawnCost()
        metabolism.withdrawFromSpawn(spawnCost)

        arkonFactory = ArkonFactory(self)
        arkonFactory!.buildNewArkon()
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
