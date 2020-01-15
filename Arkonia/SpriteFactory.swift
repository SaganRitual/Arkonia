import Foundation
import SpriteKit

enum SpriteUserDataKey {
    case manna, net9Portal, netDisplay, stepper, uuid, debug, injectedAt
    case setContentsCallback, bloomActionIx
}

typealias SpriteFactoryCallback0P = () -> Void
typealias SpriteFactoryCallback1P = (SKSpriteNode) -> Void

class SpriteHangar {
    let atlas: SKTextureAtlas?
    var parkedDrones = [SKSpriteNode]()
    let factoryFunction: FactoryFunction
    var texture: SKTexture
    var doubly = false

    init(_ atlasName: String, _ textureName: String, factoryFunction: @escaping FactoryFunction) {
        atlas = SKTextureAtlas(named: atlasName)
        self.factoryFunction = factoryFunction
        texture = atlas!.textureNamed(textureName)
    }

    func makeSprite(_ name: String?, _ onComplete: @escaping SpriteFactoryCallback1P) {
        var sprite: SKSpriteNode?
        let action = SKAction.run { sprite = self.makeSprite(name) }
        GriddleScene.shared.run(action) {
            guard let s = sprite else { fatalError() }
            onComplete(s)
        }
    }

    func setupNetPortals(_ net9Portals: [SKSpriteNode]) {
        (0..<18).forEach { ix in
            parkedDrones.append(factoryFunction(texture))
            guard let drone = parkedDrones.last else { fatalError() }
            drone.userData = [SpriteUserDataKey.net9Portal: net9Portals[ix]]
        }
    }

    func makeSprite(_ name: String?) -> SKSpriteNode {
        if parkedDrones.isEmpty { parkedDrones.append(factoryFunction(texture)) }

        guard let drone = parkedDrones.popLast() else { fatalError() }

        if drone.getKeyField(.uuid, require: false) as? String == nil {
            if drone.userData == nil { drone.userData = [:] }
            drone.userData![SpriteUserDataKey.uuid] = UUID().uuidString
        }

        drone.alpha = 0
        drone.name = name
        drone.userData![SpriteUserDataKey.debug] = name
        drone.color = .gray
        drone.colorBlendFactor = 1.0
        return drone
    }

    func retireSprite(_ sprite: SKSpriteNode, _ onComplete: @escaping () -> Void) {
        let action = SKAction.run { self.retireSprite(sprite) }
        GriddleScene.shared.run(action, completion: onComplete)
    }

    func retireSprite(_ sprite: SKSpriteNode) {
        parkedDrones.append(sprite)
        sprite.removeAllActions()
        sprite.removeFromParent()
    }
}

class SpriteFactory {
    static var shared: SpriteFactory!

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

    func postInit(_ net9Portals: [SKSpriteNode], _ onComplete: @escaping () -> Void) {
        let action = SKAction.run { self.postInit(net9Portals) }
        GriddleScene.shared.run(action, completion: onComplete)
    }

    private func postInit(_ net9Portals: [SKSpriteNode]) {
        arkonsHangar.setupNetPortals(net9Portals)
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
