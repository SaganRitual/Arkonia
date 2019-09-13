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
    var previousShift = AKPoint.zero
    let metabolism: Metabolism
    var netSignal: StepperNetSignal
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
        sprite.color = .cyan
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
        netSignal = StepperNetSignal()
        sprite.userData![SpriteUserDataKey.stepper] = self

        stepping = false
        netSignal.inject(self)
        netSignal.go()
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

            if Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
                return Gridlet.at(inputGridlet).contents.rawValue
            }

            return 0
        }

        sensoryInputs.append(1.0)//Double(metabolism.oxygenLevel))

        let xGrid = Double(gridlet.gridPosition.x)
        let yGrid = Double(gridlet.gridPosition.y)

        sensoryInputs.append(contentsOf: [xGrid, yGrid])

        sensoryInputs.append(1.0)//Double(metabolism.fungibleEnergyFullness))

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)

        sensoryInputs.append(Double(xShift))
        sensoryInputs.append(Double(yShift))

//        print("si", core.selectoid.fishNumber, sensoryInputs)
        return sensoryInputs
    }

    func metabolize() -> Bool {
        if !core.isAlive { return false }

        useEnergy()

        let oxygenCost: TimeInterval = core.age < TimeInterval(5) ? 0 : 1
        metabolism.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)
//        print("o2b", metabolism.oxygenLevel)

        guard metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0 else {
//            print("ap", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel)
            let action = SKAction.run { [weak self] in self?.core.apoptosize() }
            sprite.run(action)
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

        let ef = metabolism.fungibleEnergyFullness
        core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if core.selectoid.fishNumber < 10 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                Arkon.brightColor : Arkon.standardColor
        }

        let four: CGFloat = 4
        sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
        )

        sprite.colorBlendFactor = metabolism.oxygenLevel

        return true
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
            if targetShift == previousShift { return false }
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

        guard let tm = targetMove else { previousShift = AKPoint.zero; return AKPoint(x: 0, y: 0) }
//        print("tm", core.selectoid.fishNumber, tm.0, tm.1, Stepper.moves[tm.0])
        previousShift = targetShift * -1
        return Stepper.moves[tm.0]
    }

    func realStepComplete() {
        stepping = false
    }

    enum Stage { case notSet, selfOk, stepperOk, metabolismOk, moveOk }
    class StepperNetSignal {
        var busy = false
        weak var stepper: Stepper?

        func inject(_ stepper: Stepper) {
            self.stepper = stepper
        }

        func go() {
            if busy { return }

//            busy = true

            var shiftTarget = AKPoint.zero

            guard let st = stepper else { return }
            guard let sp = st.sprite else { return }

            let goAction = SKAction.run({ [weak self] in

//                print("d1", st.core.selectoid.fishNumber, Display.displayCycle)
                guard let myself = self else {
//                    print("x1", st.core.selectoid.fishNumber)
                    return }

                shiftTarget = AKPoint.zero

//                print("d1b", st.core.selectoid.fishNumber, Display.displayCycle)
                if !st.metabolize() {
//                    print("x1b", st.core.selectoid.fishNumber)
                    return }

                st.metabolism.tick()  // Jesu Christi this is ugly

                shiftTarget = st.selectMoveTarget(st.loadSenseData())

//                print("d1c", st.core.selectoid.fishNumber, Display.displayCycle)
                if shiftTarget == AKPoint.zero {
//                    print("x1c", st.core.selectoid.fishNumber)
                    return }

                let newGridlet = Gridlet.at(st.gridlet.gridPosition + shiftTarget)

//                let goWait = SKAction.run {} //wait(forDuration: 0.001)
                let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

                let goContents = SKAction.run {
                    defer {
                        st.gridlet.sprite = nil
                        st.gridlet.contents = .nothing
                        newGridlet.contents = .arkon
                        newGridlet.sprite = st.sprite
                        st.gridlet = newGridlet
                    }

                    myself.touchFood(eater: st, foodLocation: newGridlet)
                }

                let goSequence = SKAction.sequence([goStep, goContents])
                sp.run(goSequence) {
//                    print("d3", st.core.selectoid.fishNumber, Display.displayCycle)
                    myself.busy = false
                    myself.go()
                }

            }, queue: st.core.netQueue)

            sp.run(goAction)
        }

        func touchFood(eater: Stepper, foodLocation: Gridlet) {

            var userDataKey = SpriteUserDataKey.karamba

            switch foodLocation.contents {
            case .arkon:
                userDataKey = .stepper

                if let otherSprite = foodLocation.sprite,
                    let otherUserData = otherSprite.userData,
                    let otherAny = otherUserData[userDataKey],
                    let otherStepper = otherAny as? Stepper
                {
                    eater.touchArkon(otherStepper)
                }

            case .manna:
                userDataKey = .manna

                if let otherSprite = foodLocation.sprite,
                    let otherUserData = otherSprite.userData,
                    let otherAny = otherUserData[userDataKey],
                    let manna = otherAny as? Manna
                {
                    eater.touchManna(manna)
                }

            case .nothing: break
            }

        }
    }

}

extension Stepper {

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Stepper {

        let newStepper = Stepper(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        return newStepper
    }

    func tick() {
        metabolism.tick()
        core.tick()
    }

    func touchArkon(_ victimStepper: Stepper) {
        if metabolism.mass > (victimStepper.metabolism.mass * 1.25) {
            metabolism.parasitize(victimStepper.metabolism)
            victimStepper.core.apoptosize()
        }
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
