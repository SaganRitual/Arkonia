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
    weak var gridlet: Gridlet!
    var isAlive = false
    var isApoptosizing = false
    var stepperIsEngaged = true
    var stepperIsEngaged2 = false
    var metabolism: Metabolism!
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

        self.sprite = self.core.sprite
        self.sprite.color = .cyan
        self.sprite.setScale(0.5)

        self.metabolism = Metabolism(core: self.core)
        self.coordinator = Coordinator(stepper: self)

        var theRP: Grid.RandomGridPoint?

                func postRP(_ rp: Grid.RandomGridPoint) {
                    theRP = rp

                    self.gridlet = rp.gridlet
                    self.gridlet.contents = .arkon
                    self.gridlet.sprite = self.core.sprite

                    self.sprite.position = self.gridlet.scenePosition
                    self.sprite.userData![SpriteUserDataKey.stepper] = self
                }

        theRP = Stepper.setOffspringPosition(parentPosition: parentPosition)
        if theRP == nil {
            Grid.getRandomPoint(
                sprite: sprite, background: Arkon.arkonsPortal!
            ) { postRP($0) }

            return
        }

        postRP(theRP!)
    }

    deinit {
//        print("stepper deinit")
    }

    static func setOffspringPosition(parentPosition: AKPoint?) -> Grid.RandomGridPoint? {

        if let pp = parentPosition {
            for offset in Stepper.gridInputs {
                let offspringPosition = pp + offset

                if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {
                    let gridlet = Gridlet.at(offspringPosition)
                    if gridlet.contents == .nothing {
                        return Grid.RandomGridPoint(gridlet: gridlet, cgPoint: gridlet.scenePosition)
                    }
                }
            }
        }

        return nil
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

    static func spawn_(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?, parentPosition: AKPoint?
    ) -> Stepper {
    }

    func tick() { assert(false) }
}
