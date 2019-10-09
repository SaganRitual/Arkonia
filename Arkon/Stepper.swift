import SpriteKit

extension SKSpriteNode {
    var stepper: Stepper {
        get { return (userData![SpriteUserDataKey.stepper] as? Stepper)! }
        set { userData![SpriteUserDataKey.stepper] = newValue }
    }

    var optionalStepper: Stepper? { return userData?[SpriteUserDataKey.stepper] as? Stepper }
}

class Stepper {
    static let moves = [
         AKPoint(x: 0, y:   1), AKPoint(x:  1, y:  1), AKPoint(x:  1, y:  0),
         AKPoint(x: 1, y:  -1), AKPoint(x:  0, y: -1), AKPoint(x: -1, y: -1),
         AKPoint(x: -1, y:  0), AKPoint(x: -1, y:  1)
    ]

    static let gridInputs = [
        AKPoint(x: -4, y:  4), AKPoint(x: -3, y:  4), AKPoint(x: -2, y:  4), AKPoint(x: -1, y:  4), AKPoint(x:   0, y:  4), AKPoint(x:  1, y:  4), AKPoint(x:  2, y:  4), AKPoint(x:  3, y:  4), AKPoint(x:  4, y:  4),
        AKPoint(x: -4, y:  3), AKPoint(x: -3, y:  3), AKPoint(x: -2, y:  3), AKPoint(x: -1, y:  3), AKPoint(x:   0, y:  3), AKPoint(x:  1, y:  3), AKPoint(x:  2, y:  3), AKPoint(x:  3, y:  3), AKPoint(x:  4, y:  3),
        AKPoint(x: -4, y:  2), AKPoint(x: -3, y:  2), AKPoint(x: -2, y:  2), AKPoint(x: -1, y:  2), AKPoint(x:   0, y:  2), AKPoint(x:  1, y:  2), AKPoint(x:  2, y:  2), AKPoint(x:  3, y:  2), AKPoint(x:  4, y:  2),
        AKPoint(x: -4, y:  1), AKPoint(x: -3, y:  1), AKPoint(x: -2, y:  1), AKPoint(x: -1, y:  1), AKPoint(x:   0, y:  1), AKPoint(x:  1, y:  1), AKPoint(x:  2, y:  1), AKPoint(x:  3, y:  1), AKPoint(x:  4, y:  1),
        AKPoint(x: -4, y:  0), AKPoint(x: -3, y:  0), AKPoint(x: -2, y:  0), AKPoint(x: -1, y:  0), AKPoint(x:   0, y:  0), AKPoint(x:  1, y:  0), AKPoint(x:  2, y:  0), AKPoint(x:  3, y:  0), AKPoint(x:  4, y:  0),
        AKPoint(x: -4, y: -1), AKPoint(x: -3, y: -1), AKPoint(x: -2, y: -1), AKPoint(x: -1, y: -1), AKPoint(x:   0, y: -1), AKPoint(x:  1, y: -1), AKPoint(x:  2, y: -1), AKPoint(x:  3, y: -1), AKPoint(x:  4, y: -1),
        AKPoint(x: -4, y: -2), AKPoint(x: -3, y: -2), AKPoint(x: -2, y: -2), AKPoint(x: -1, y: -2), AKPoint(x:   0, y: -2), AKPoint(x:  1, y: -2), AKPoint(x:  2, y: -2), AKPoint(x:  3, y: -2), AKPoint(x:  4, y: -2),
        AKPoint(x: -4, y: -3), AKPoint(x: -3, y: -3), AKPoint(x: -2, y: -3), AKPoint(x: -1, y: -3), AKPoint(x:   0, y: -3), AKPoint(x:  1, y: -3), AKPoint(x:  2, y: -3), AKPoint(x:  3, y: -3), AKPoint(x:  4, y: -3),
        AKPoint(x: -4, y: -4), AKPoint(x: -3, y: -4), AKPoint(x: -2, y: -4), AKPoint(x: -1, y: -4), AKPoint(x:   0, y: -4), AKPoint(x:  1, y: -4), AKPoint(x:  2, y: -4), AKPoint(x:  3, y: -4), AKPoint(x:  4, y: -4)
    ]

    var coordinator: Coordinator!
    let core: Arkon
    var gridlet: Gridlet
    var isAlive = false
    var isApoptosizing = false
    var isEngaged = false
    let metabolism: Metabolism
    var newGridlet: Gridlet?
    var oldGridlet: Gridlet?
    weak var parasitismVictim: Stepper?
    var previousShift = AKPoint.zero
    var shiftTarget = AKPoint.zero
    weak var sprite: SKSpriteNode!
    var stepping = true

    init(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?, parentPosition: AKPoint?
    ) {

        self.core = Arkon(
            parentBiases: parentBiases, parentWeights: parentWeights,
            layers: layers, parentActivator: parentActivator
        )

        let rp = Stepper.setOffspringPosition(parentPosition: parentPosition)

        self.gridlet = rp.0
        self.gridlet.contents = .arkon
        self.sprite = core.sprite
        self.gridlet.sprite = core.sprite

        sprite.color = .cyan
        sprite.position = gridlet.scenePosition
        sprite.setScale(0.5)

        metabolism = Metabolism(core: core)
        coordinator = Coordinator(stepper: self)
        sprite.userData![SpriteUserDataKey.stepper] = self

        stepping = false
    }

    deinit {
//        print("stepper deinit")
    }

    static func setOffspringPosition(parentPosition: AKPoint?) -> (Gridlet, CGPoint) {

        if let pp = parentPosition {
            for offset in Stepper.gridInputs {
                let offspringPosition = pp + offset

                if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {
                    let gridlet = Gridlet.at(offspringPosition)
                    if gridlet.contents == .nothing {
                        return (gridlet, gridlet.scenePosition)
                    }
                }
            }
        }

        var rp: (Gridlet, CGPoint)
        var gridlet: Gridlet

        repeat {
            rp = Arkon.arkonsPortal!.getRandomPoint()
            gridlet = rp.0
        } while gridlet.contents != .nothing

        return rp
    }

}

extension Stepper {

    static func spawn(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?, parentPosition: AKPoint?
    ) -> Stepper {

        let newStepper = Stepper(
            parentBiases: parentBiases, parentWeights: parentWeights,
            layers: layers, parentActivator: parentActivator,
            parentPosition: parentPosition
        )

        return newStepper
    }

    func tick() { assert(false) }
}
