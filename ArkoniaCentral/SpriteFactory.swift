import Foundation
import SpriteKit

enum SpriteUserDataKey {
    case manna, net9Portal, netDisplay, stepper
}

class SpriteHangar: SpriteHangarProtocol {
    let atlas: SKTextureAtlas?
    var drones = [SKSpriteNode]()
    let factoryFunction: FactoryFunction
    var texture: SKTexture
    var doubly = false

    init(_ atlasName: String, _ textureName: String, factoryFunction: @escaping FactoryFunction) {
        atlas = SKTextureAtlas(named: atlasName)
        self.factoryFunction = factoryFunction
        texture = atlas!.textureNamed(textureName)
    }

    func makeSprite() -> SKSpriteNode {
        if let readyDrone = drones.first(where: { sprite in sprite.parent == nil }) {
            return readyDrone
        }

        let newSprite = factoryFunction(texture)
        newSprite.alpha = 0
        newSprite.userData = [:]
        newSprite.name = UUID().uuidString
        drones.append(newSprite)
        return newSprite
    }

    func retireSprite(_ sprite: SKSpriteNode) {
        sprite.parent!.run(SKAction.run {
            sprite.removeAllActions()
            sprite.removeFromParent()
        })
    }
}

class SpriteFactory {
    let arkonsHangar: SpriteHangar
    let fullNeuronsHangar: SpriteHangar
    let halfNeuronsHangar: SpriteHangar
    let linesHangar: SpriteHangar
    let mannaHangar: SpriteHangar
    let noseHangar: SpriteHangar
    let scene: SKScene
    var count = 0

    init(scene: SKScene, thoraxFactory: @escaping FactoryFunction, noseFactory: @escaping FactoryFunction) {
        self.scene = scene

        arkonsHangar =      SpriteHangar("Arkons",  "spark-thorax-large",  factoryFunction: thoraxFactory)
        fullNeuronsHangar = SpriteHangar("Neurons", "neuron-plain",        factoryFunction: SpriteFactory.makeSprite)
        halfNeuronsHangar = SpriteHangar("Neurons", "neuron-plain-half",   factoryFunction: SpriteFactory.makeSprite)
        linesHangar =       SpriteHangar("Line",    "line",                factoryFunction: SpriteFactory.makeSprite)
        mannaHangar =       SpriteHangar("Manna",   "manna",               factoryFunction: SpriteFactory.makeSprite)
        noseHangar =        SpriteHangar("Arkons",  "spark-nose-large",    factoryFunction: noseFactory)
    }

    func postInit(_ net9Portals: [SKSpriteNode]) {
        for i in 0..<18 {
            let drone = arkonsHangar.makeSprite()
            drone.userData![SpriteUserDataKey.net9Portal] = net9Portals[i]
            scene.addChild(drone)   // Icky -- adding to scene to hold temp space in hangar
        }

        for drone in arkonsHangar.drones { arkonsHangar.retireSprite(drone) }
    }
}

extension SpriteFactory {

    static func drawLine(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)
        line.strokeColor = color
        line.lineWidth = 3
        line.zPosition = 10
        return line
    }
}

extension SpriteFactory {
    static func makeFakeNose(texture: SKTexture) -> SKSpriteNode {
        return SKSpriteNode(texture: texture)
    }

    static func makeFakeThorax(texture: SKTexture) -> SKSpriteNode {
        return SKSpriteNode(texture: texture)
    }

    static func makeSprite(texture: SKTexture) -> SKSpriteNode {
        return SKSpriteNode(texture: texture)
    }
}

extension SpriteFactory {
    static var count = 0
    static var phaseIndicator = SKColor.green
}
