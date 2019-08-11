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
        self.step(by: 0, 0)
    }

    static let moves = [
         AKPoint(x: 0, y:   1), AKPoint(x:  1, y:  1), AKPoint(x:  1, y:  0),
         AKPoint(x: 1, y:  -1), AKPoint(x:  0, y: -1), AKPoint(x: -1, y: -1),
         AKPoint(x: -1, y:  0), AKPoint(x: -1, y:  1)
    ]

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
        let waitAction = SKAction.wait(forDuration: 0.7)
        let sequence = SKAction.sequence([waitAction, stepAction])
        sprite.run(sequence) { self.stepComplete(newGridlet) }
    }

    func stepComplete(_ newGridlet: Gridlet) {
        self.gridlet = newGridlet

        let mm = Stepper.moves.randomElement()!
//        print("gq1", self.sprite.position.x, self.sprite.position.y, mm.x, mm.y)
        self.step(by: mm.x, mm.y)
//        print("gq2", self.sprite.position.x, self.sprite.position.y, mm.x, mm.y)
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
}
