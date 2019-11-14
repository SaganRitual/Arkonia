import SpriteKit

class Stepper {
    let allowSpawning = true
    var birthday = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var fishNumber = 0
    weak var gridCell: GridCell!
    var metabolism: Metabolism!
    let name = UUID().uuidString
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
        self.gridCell = embryo.gridCell
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
        print("stepper deinit", name)
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
        Grid.shared.serialQueue.sync {
            sprite.userData![SpriteUserDataKey.stepper] = stepper
            sprite.name = stepper.name
            print("attachStepper", sprite.name ?? "no sprite name?", stepper.name)
        }
    }

    static func getStepper(from sprite: SKSpriteNode, require: Bool = true) -> Stepper? {
        func failIf() { if require { fatalError() } }

        if sprite.name == nil {
            print("nothing")
            failIf()
            return nil
        }

        guard let userData = sprite.userData
            else { print("sprite name \(sprite.name ?? "wtf?")"); failIf(); return nil }

        guard let embryo = userData[SpriteUserDataKey.stepper]
            else { print("sprite name \(sprite.name ?? "wtf?") userData \(userData)"); failIf(); return nil }

        guard let stepper = embryo as? Stepper
            else { print("sprite name \(sprite.name ?? "wtf?") userData \(userData)"); failIf(); return nil }

        return stepper
    }

    static func releaseStepper(_ stepper: Stepper, from sprite: SKSpriteNode) {
        Grid.shared.serialQueue.sync {
            print("detachStepper", stepper.name, sprite.name ?? "no sprite name")
            if sprite.userData![SpriteUserDataKey.stepper] == nil { fatalError() }
            sprite.userData![SpriteUserDataKey.stepper] = nil
        }
    }
}
