import SpriteKit

extension SKSpriteNode {
    var stepper: Stepper {
        get { return (userData![SpriteUserDataKey.stepper] as? Stepper)! }
        set { userData![SpriteUserDataKey.stepper] = newValue }
    }

    var optionalStepper: Stepper? { return userData?[SpriteUserDataKey.stepper] as? Stepper }
}

class Stepper {
    let core: Arkon
    var gridlet: Gridlet
    let metabolism: MetabolismProtocol
    let sprite: SKSpriteNode

    init(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) {
        self.core = Arkon(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        let wGrid = Int(CGFloat(Griddle.dimensions.wGrid) / 2)
        let hGrid = Int(CGFloat(Griddle.dimensions.hGrid) / 2)

        let ak = AKPoint.random(-wGrid..<wGrid, -hGrid..<hGrid)

        gridlet = Gridlet.at(ak.x, ak.y)

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

        self.step(by: 0, 0)
    }

    static let moves = [
         AKPoint(x: 0, y:   1), AKPoint(x:  1, y:  1), AKPoint(x:  1, y:  0),
         AKPoint(x: 1, y:  -1), AKPoint(x:  0, y: -1), AKPoint(x: -1, y: -1),
         AKPoint(x: -1, y:  0), AKPoint(x: -1, y:  1)
    ]

//    func getTargetGridlet() -> Gridlet {
//        let adjacentObjects: [Gridlet] = Stepper.moves.map { step in
//            let inputGridlet = step + gridlet.gridPosition
//            return Gridlet.at(inputGridlet).contents.rawValue
//        }
//    }

//    var counter = 0

    func step(by x: Int, _ y: Int) {
//        counter += 1
//        if counter >= 3 { return }
        let newGridlet = Gridlet.at(gridlet.gridPosition.x + x, gridlet.gridPosition.y + y)
//        print(
//            "ng",
//            gridlet.gridPosition.x, gridlet.gridPosition.y,
//            gridlet.scenePosition.x, gridlet.scenePosition.y,
//            x, y,
//            newGridlet.gridPosition.x, newGridlet.gridPosition.y,
//            newGridlet.scenePosition.x, newGridlet.scenePosition.y,
//            sprite.position.x, sprite.position.y
//        )

        let scenePosition = newGridlet.scenePosition
        let stepAction = SKAction.move(to: scenePosition, duration: 0.1)
        let waitAction = SKAction.wait(forDuration: 0.01)
        let sequence = SKAction.sequence([waitAction, stepAction])
        sprite.run(sequence) { self.stepComplete(newGridlet) }
    }

    func getSenseDataAsDictionary(_ senseData: [Double?]) -> [Int: Double?] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    func selectMoveTarget(_ senseData: [Int: Double?]) -> AKPoint {

        let order: [(Int, Double?)] = senseData.sorted { lhs, rhs in
            guard let ld = lhs.value else { return false }
            guard let rd = rhs.value else { return true }
            return Double(ld) > Double(rd)
        }

        return Stepper.moves[order[0].0]
    }

    func stepComplete(_ newGridlet: Gridlet) {
        if newGridlet.contents == .manna {
            touchManna((newGridlet.sprite!.userData![SpriteUserDataKey.manna]! as? Manna)!)
        }

        let senseData = getSenseDataAsDictionary(loadSenseData())
        let moveTarget = selectMoveTarget(senseData)

        self.gridlet = newGridlet
        self.step(by: moveTarget.x, moveTarget.y)
    }

    func loadSenseData() -> [Double?] {
        let sensoryInputs: [Double?] = Stepper.moves.map { step in
            let inputGridlet = step + gridlet.gridPosition
            return Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) ?
                    Gridlet.at(inputGridlet).contents.rawValue : nil
        }

        return sensoryInputs
    }
}

extension Stepper {

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Stepper {

        let newStepper = Stepper(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

//        newStepper.sprite.position = Arkon.arkonsPortal!.getRandomPoint()
        newStepper.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

//        onePass(sprite: newKaramba.sprite, metabolism: newKaramba.metabolism)

        return newStepper
    }

    func touchManna(_ manna: Manna) {
        let sprite = manna.sprite
        let background = (sprite.parent as? SKSpriteNode)!

        let harvested = sprite.manna.harvest()
        metabolism.absorbEnergy(harvested)

        let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
        sprite.run(actions)
    }
}
