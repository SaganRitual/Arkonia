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
         AKPoint(x: -2, y:  2), AKPoint(x: -1, y:  2), AKPoint(x:  0, y:  2), AKPoint(x:  1, y:  2), AKPoint(x: 2, y:  2),
         AKPoint(x: -2, y:  1), AKPoint(x: -1, y:  1), AKPoint(x:  0, y:  1), AKPoint(x:  1, y:  1), AKPoint(x: 2, y:  1),
         AKPoint(x: -2, y:  0), AKPoint(x: -1, y:  0), AKPoint(x:  0, y:  0), AKPoint(x:  1, y:  0), AKPoint(x: 2, y:  0),
         AKPoint(x: -2, y: -1), AKPoint(x: -1, y: -1), AKPoint(x:  0, y: -1), AKPoint(x:  1, y: -1), AKPoint(x: 2, y: -1),
         AKPoint(x: -2, y: -2), AKPoint(x: -1, y: -2), AKPoint(x:  0, y: -2), AKPoint(x:  1, y: -2), AKPoint(x: 2, y: -2)
    ]

    let core: Arkon
    var gridlet: Gridlet
    let metabolism: Metabolism
    weak var sprite: SKSpriteNode!
    var stepping = true

    init(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) {
        self.core = Arkon(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        var rp: (Gridlet, CGPoint)
        repeat {
            rp = Arkon.arkonsPortal!.getRandomPoint()
            gridlet = rp.0
        } while gridlet.contents != .nothing

        gridlet.contents = .arkon
        self.sprite = core.sprite// Arkon.spriteFactory!.arkonsHangar.makeSprite()

//        Arkon.arkonsPortal!.addChild(sprite)
        sprite.color = .white
        sprite.position = gridlet.scenePosition
        sprite.setScale(0.5)

//        print(
//            "st",
//            gridlet.gridPosition.x, gridlet.gridPosition.y,
//            gridlet.scenePosition.x, gridlet.scenePosition.y,
//            sprite.position.x, sprite.position.y,
//            ak.x, ak.y
//        )

//        stepComplete(gridlet)

        metabolism = Metabolism()
        sprite.userData![SpriteUserDataKey.stepper] = self

        stepping = false
    }

//    deinit {
//        print("Stepper deinit")
//    }

//    func getTargetGridlet() -> Gridlet {
//        let adjacentObjects: [Gridlet] = Stepper.moves.map { step in
//            let inputGridlet = step + gridlet.gridPosition
//            return Gridlet.at(inputGridlet).contents.rawValue
//        }
//    }

//    var counter = 0

    func getMotorDataAsDictionary(_ senseData: [Double]) -> [Int: Double] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    func loadSenseData() -> [Double] {
        var sensoryInputs: [Double] = Stepper.gridInputs.map { step in
            let inputGridlet = step + gridlet.gridPosition
            return Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) ?
                    Gridlet.at(inputGridlet).contents.rawValue : 0
        }

        sensoryInputs.append(Double(metabolism.oxygenLevel))

        let r = Double(sprite.position.radius / Arkon.arkonsPortal!.size.hypotenuse)
        let theta = Double(sprite.position.theta / Arkon.arkonsPortal!.size.hypotenuse)

        sensoryInputs.append(contentsOf: [r, theta])

        sensoryInputs.append(Double(metabolism.fungibleEnergyFullness))

//        print("si", core.selectoid.fishNumber, sensoryInputs)
        return sensoryInputs
    }

    func metabolize() -> Bool {

        useEnergy()

        let oxygenCost: TimeInterval = core.age < TimeInterval(5) ? 0 : 1
        metabolism.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)
//        print("o2b", metabolism.oxygenLevel)

        guard metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0 else {
//            print("ap", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel)
            core.apoptosize()
            return false
        }

        // 10% entropy
        let spawnCost = EnergyReserve.startingEnergyLevel * 1.10

//        print("msrv", metabolism.spawnReserves.level, spawnCost)
        if metabolism.spawnReserves.level >= spawnCost {
            metabolism.withdrawFromSpawn(spawnCost)

            let biases = core.net.biases
            let weights = core.net.weights
            let layers = core.net.layers
            let waitAction = SKAction.wait(forDuration: 0.02)
            let spawnAction = SKAction.run {
                Stepper.spawn(parentBiases: biases, parentWeights: weights, layers: layers)
            }

            let sequence = SKAction.sequence([waitAction, spawnAction])
            Arkon.arkonsPortal!.run(sequence) {
                self.core.selectoid.cOffspring += 1
                World.shared.registerCOffspring(self.core.selectoid.cOffspring)
            }

        }

//        let ef = metabolism.fungibleEnergyFullness
//        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

//        let baseColor: Int
//        if core.selectoid.fishNumber < 10 {
//            baseColor = 0xFF_00_00
//        } else {
//            baseColor = (metabolism.spawnEnergyFullness > 0) ?
//                Arkon.brightColor : Arkon.standardColor
//        }

//        let four: CGFloat = 4
        sprite.color = .green /*ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
        )*/

        sprite.colorBlendFactor = metabolism.oxygenLevel

        return true
    }

    func selectMoveTarget(_ sensoryInputs: [Double]) -> AKPoint {
        let motorOutputs = core.net.getMotorOutputs(sensoryInputs)
        let dMotorOutputs = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in Double(lhs.1) > Double(rhs.1) }
        let targetMove = order.first { entry in
            let targetShift = Stepper.moves[entry.0]
//            print("ts", core.selectoid.fishNumber, targetShift)
            if abs(targetShift.x) > 1 || abs(targetShift.y) > 1 { return false }

            let targetGridPosition = targetShift + gridlet.gridPosition
            if !Gridlet.isOnGrid(targetGridPosition.x, targetGridPosition.y) { return false }

            let testGridlet = Gridlet.at(targetGridPosition)

//            print(
//                "tg", core.selectoid.fishNumber, gridlet.gridPosition,
//                testGridlet.gridPosition, testGridlet.scenePosition,
//                self.gridlet.contents, testGridlet.contents
//            )

            return testGridlet.contents != .arkon
        }

        guard let tm = targetMove else { return AKPoint(x: 0, y: 0) }
//        print("tm", core.selectoid.fishNumber, tm.0, tm.1, Stepper.moves[tm.0])
        return Stepper.moves[tm.0]
    }

    func realStepComplete() {
        stepping = false
    }

    func realStep() {
        if stepping { return }
        stepping = true

        let waitAction = SKAction.wait(forDuration: 0.02)
        var actions = [waitAction]

        defer {
            let sequence = SKAction.sequence(actions)
            sprite?.run(sequence) { [weak self] in self?.realStepComplete() }
        }

        if !metabolize() { return }
        tick()  // Jesu Christi this is ugly

        let shiftTarget = selectMoveTarget(loadSenseData())
        if shiftTarget == AKPoint.zero { return }

        let newGridlet = Gridlet.at(self.gridlet.gridPosition + shiftTarget)

        let stepAction = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        actions.append(stepAction)

//        print("rsng", shiftTarget, newGridlet.gridPosition)

        let contentsAction = SKAction.run {
            if newGridlet.contents == .manna { self.touchManna(newGridlet.sprite!.manna) }

            self.gridlet.contents = .nothing
            newGridlet.contents = .arkon
            self.gridlet = newGridlet
        }
        actions.append(contentsAction)
    }
}

extension Stepper {

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Stepper {

//        print("spawn")
        let newStepper = Stepper(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

//        print("ns", newStepper.gridlet.gridPosition, newStepper.gridlet.scenePosition)
        return newStepper
    }

    func tick() {
        metabolism.tick()
        core.tick()
    }

    func touchManna(_ manna: Manna) {
        // I guess I've died already?
        guard let background = sprite?.parent as? SKSpriteNode else { return }

        let sprite = manna.sprite

        let harvested = sprite.manna.harvest()
        metabolism.absorbEnergy(harvested)
        metabolism.inhale()

        let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
        sprite.run(actions)
    }

    func useEnergy() {
        let fudgeFactor: CGFloat = 0.2
        let targetSpeed: CGFloat = 0.1 * 1000  // some random # * 1000 pixels/sec
        let joulesNeeded = fudgeFactor * abs(targetSpeed) * metabolism.mass

        _ = self.metabolism.withdrawFromReady(joulesNeeded)
    }
}
