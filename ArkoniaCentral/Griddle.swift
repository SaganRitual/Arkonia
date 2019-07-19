import SpriteKit

struct AKPoint {
    let x: Int; let y: Int
}

class Gridlet {
    var contents = Contents.nothing
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }
}

extension Gridlet {

    enum Contents {
        case arkon, manna, nothing
    }

}

struct Dimensions {
    let hPortal: Int
    let wPortal: Int
    let hSprite: Int
    let wSprite: Int

    init(_ hPortal: Int, _ hSprite: Int, _ wPortal: Int, _ wSprite: Int) {
        self.hPortal = hPortal
        self.hSprite = hSprite
        self.wPortal = wPortal
        self.wSprite = wSprite
    }
}

class Stepper {
    let gridlets: [Gridlet]
    let sprite: SKSpriteNode
    var ss = 0

    init(_ portal: SKSpriteNode, _ spriteFactory: SpriteFactory, _ gridlets: [Gridlet]) {
        self.gridlets = gridlets
        self.sprite = spriteFactory.arkonsHangar.makeSprite()

        portal.addChild(sprite)
        sprite.position = gridlets[ss].scenePosition
        sprite.setScale(0.5)
        step(ss + 1)
    }

    func step(_ index: Int) {
        let scenePosition = gridlets[index].scenePosition
        let stepAction = SKAction.move(to: scenePosition, duration: 0.02)
        let waitAction = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([stepAction, waitAction])
        sprite.run(sequence) {
            print("index", index)
            self.step(index + 1)
        }
    }
}

class Griddle {
    let dimensions: Dimensions
    var gridlets = [Gridlet]()
    var stepper: Stepper!

    init(_ portal: SKSpriteNode, _ spriteFactory: SpriteFactory) {
        dimensions = Griddle.setDimensions(portal)
        drawGridLines(portal)
        setupGrid(portal)
        stepper = Stepper(portal, spriteFactory, gridlets)
    }

    func drawGridLines(_ portal: SKSpriteNode) {
        let d = dimensions

        for x in stride(from: -d.wPortal, to: d.wPortal, by: d.wSprite) {
            let line = SpriteFactory.drawLine(
                from: CGPoint(x: x, y: -d.hPortal),
                to: CGPoint(x: x, y: d.hPortal),
                color: .gray
            )

            portal.addChild(line)
        }

        print("w", d.wPortal * 2 / d.wSprite, d.hPortal * 2 / d.hSprite)

        for y in stride(from: -d.hPortal, to: d.hPortal, by: d.hSprite) {
            let line = SpriteFactory.drawLine(
                from: CGPoint(x: -d.wPortal, y: y),
                to: CGPoint(x: d.wPortal, y: y),
                color: .gray
            )

            portal.addChild(line)
        }
    }

    static func setDimensions(_ portal: SKSpriteNode) -> Dimensions {
        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("spark-thorax-large")

        let hPortal = Int((1 / Arkon.scaleFactor) * portal.size.height / 2)
        let wPortal = Int((1 / Arkon.scaleFactor) * portal.size.width / 2)
        let hSprite = Int(tTexture.size().height) / 2
        let wSprite = Int(tTexture.size().width) / 2

        return Dimensions(hPortal, hSprite, wPortal, wSprite)
    }

    func setupGrid(_ portal: SKSpriteNode) {
        let d = dimensions
        var xGrid = 0, yGrid = 0

        for yScene in stride(from: -d.hPortal, to: d.hPortal, by: d.hSprite) {

            for xScene in stride(from: -d.wPortal, to: d.wPortal, by: d.wSprite) {

                let gridlet = Gridlet(
                    gridPosition: AKPoint(x: xGrid, y: -yGrid),
                    scenePosition: CGPoint(x: xScene, y: -yScene)
                )

                gridlets.append(gridlet)

                xGrid += 1
            }

            yGrid += 1
        }
    }

}
