import SpriteKit

class Stepper {
    typealias OnComplete1 = (Stepper) -> Void
    typealias OnComplete2 = (Stepper, Stepper) -> Void

    var birthday: TimeInterval!
    var cOffspring = 0
    var fishNumber = 0
    weak var gridletWithRandom: Grid.RandomGridPoint!
    weak var gridlet: Gridlet!
    var isApoptosizing = false
    var metabolism: Metabolism!
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
    var shiftTarget = AKPoint.zero
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
            return nil
        })
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
