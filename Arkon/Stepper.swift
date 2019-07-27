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

        let wGrid = Griddle.dimensions.wGrid / 2 - 1
        let hGrid = Griddle.dimensions.hGrid / 2 - 1

        let ak = AKPoint.random(-wGrid..<wGrid, -hGrid..<hGrid)

        print("st", ak.x, ak.y, wGrid, hGrid, ak.x + wGrid, ak.y + hGrid)

        gridlet = Gridlet.at(ak.x, ak.y)

        self.sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()

        Arkon.arkonsPortal!.addChild(sprite)
        sprite.position = gridlet.scenePosition
        sprite.setScale(0.5)

        let xx = Int.random(in: -1...1)
        let yy = Int.random(in: -1...1)
        self.step(by: xx, yy)
    }

    static let moves = [
         AKPoint(x: 0, y:   1), AKPoint(x:  1, y:  1), AKPoint(x:  1, y:  0),
         AKPoint(x: 1, y:  -1), AKPoint(x:  0, y: -1), AKPoint(x: -1, y: -1),
         AKPoint(x: -1, y:  0), AKPoint(x: -1, y:  1)
    ]

    func step(by x: Int, _ y: Int) {
        let newGridlet = Gridlet.at(gridlet.gridPosition.x + x, gridlet.gridPosition.y + y)
        print(
            "ng",
            gridlet.gridPosition.x, gridlet.gridPosition.y,
            gridlet.scenePosition.x, gridlet.scenePosition.y,
            x, y,
            newGridlet.gridPosition.x, newGridlet.gridPosition.y,
            newGridlet.scenePosition.x, newGridlet.scenePosition.y
        )

        let scenePosition = newGridlet.scenePosition
        let stepAction = SKAction.move(to: scenePosition, duration: 0.5)
        let waitAction = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([stepAction, waitAction])
        sprite.run(sequence) {
            self.gridlet = newGridlet

            let mm = Stepper.moves.randomElement()!
            self.step(by: mm.x, mm.y)
            print("gq", mm.x, mm.y)
        }
    }
}

extension Stepper {

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Stepper {

        let newStepper = Stepper(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        newStepper.sprite.position = Arkon.arkonsPortal!.getRandomPoint()
        newStepper.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

//        onePass(sprite: newKaramba.sprite, metabolism: newKaramba.metabolism)

        return newStepper
    }
}
