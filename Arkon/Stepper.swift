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

    let core: Arkon
    var gridlet: Gridlet
    var previousShift = AKPoint.zero
    let metabolism: Metabolism
    weak var sprite: SKSpriteNode!
    var stepping = true
    var tickStatum: TickStatum?

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

        sprite.color = .cyan
        sprite.position = gridlet.scenePosition
        sprite.setScale(0.5)

        metabolism = Metabolism()
        sprite.userData![SpriteUserDataKey.stepper] = self

        stepping = false

        tickStatum = TickStatum(stepper: self)
    }

    deinit {
//        netSignal = nil
    }

    func getMotorDataAsDictionary(_ senseData: [Double]) -> [Int: Double] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    func loadSenseData() -> [Double] {
        let sensoryInputs_: [(Double, Double)] = Stepper.gridInputs.map { step in

            let inputGridlet = step + gridlet.gridPosition

            if Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
                let targetGridlet = Gridlet.at(inputGridlet)

                let contents = Gridlet.at(inputGridlet).contents
                let rvContents = contents.rawValue
                let nutrition: Double
                switch contents {
                case .arkon:
                    nutrition = Double(targetGridlet.sprite?.stepper.metabolism.energyFullness ?? 0)

                case .manna:
                    nutrition = Double(targetGridlet.sprite?.manna.energyContentInJoules ?? 0)

                case .nothing:
                    nutrition = 0
                }

                return (rvContents, nutrition)
            }

            return (Gridlet.Contents.nothing.rawValue, -1e6)
        }

        var (sensoryInputs, nutritionses) = sensoryInputs_.reduce(into: ([Double](), [Double]())) {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }

        sensoryInputs.append(contentsOf: nutritionses)

        let xGrid = Double(gridlet.gridPosition.x)
        let yGrid = Double(gridlet.gridPosition.y)
        sensoryInputs.append(contentsOf: [xGrid, yGrid])

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        sensoryInputs.append(contentsOf: [xShift, yShift])

        return sensoryInputs
    }

    func selectMoveTarget(_ sensoryInputs: [Double]) -> AKPoint {
        let motorOutputs: [Double] = core.net.getMotorOutputs(sensoryInputs)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        var targetShift = AKPoint.zero
        let targetMove = order.first { entry in
            targetShift = Stepper.moves[entry.0]

//            print("ts", core.selectoid.fishNumber, targetShift)
            if abs(targetShift.x) > 1 || abs(targetShift.y) > 1 { return false }

            let targetGridPosition = targetShift + gridlet.gridPosition
            if !Gridlet.isOnGrid(targetGridPosition.x, targetGridPosition.y) { return false }

            let testGridlet = Gridlet.at(targetGridPosition)
            var isAlreadyEngaged = true

            DispatchQueue.main.sync {
                isAlreadyEngaged = testGridlet.isEngaged

                if !isAlreadyEngaged {
                    testGridlet.isEngaged = true
                }
            }

//            print(
//                "tg", core.selectoid.fishNumber, gridlet.gridPosition,
//                testGridlet.gridPosition, testGridlet.scenePosition,
//                self.gridlet.contents, testGridlet.contents
//            )

            return !isAlreadyEngaged
        }

        guard let tm = targetMove else { previousShift = AKPoint.zero; return AKPoint.zero }
//        print("tm", core.selectoid.fishNumber, tm.0, tm.1, Stepper.moves[tm.0])
        previousShift = targetShift * -1
        return Stepper.moves[tm.0]
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

    @discardableResult
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
