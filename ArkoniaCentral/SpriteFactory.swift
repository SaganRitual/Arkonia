import Foundation
import SpriteKit

enum SpriteUserDataKey {
    case karamba, manna, net9Portal, netDisplay, stepper
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
        assert(doubly == false)
        defer { doubly = false }
        doubly = true
        if let readyDrone = drones.first(where: { sprite in sprite.parent == nil }) {
            return readyDrone
        }

        let newSprite = factoryFunction(texture)
        newSprite.userData = [:]
        drones.append(newSprite)
        return newSprite
    }

    func retireSprite(_ sprite: SKSpriteNode) {
        sprite.removeAllActions()
        sprite.removeFromParent()
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
}

extension SpriteFactory {
    static var count = 0
    static var phaseIndicator = SKColor.green

    static func makeDestroyAction(factory: SpriteFactory) -> SKAction {
        let destroyOne = SKAction.run {
            SpriteFactory.count -= 1

            (0..<5).forEach { _ in
                guard let doomed = factory.scene.children.randomElement() as? SKSpriteNode
                    else { preconditionFailure() }

                doomed.removeFromParent()
                doomed.color = SpriteFactory.phaseIndicator
                doomed.colorBlendFactor = 1
            }
        }

        return destroyOne
    }

    static func makeFinalReleaseAction(factory: SpriteFactory) -> SKAction {
        let finalReleaseOne = SKAction.run {
            factory.arkonsHangar.drones.removeLast()
            factory.fullNeuronsHangar.drones.removeLast()
            factory.halfNeuronsHangar.drones.removeLast()
            factory.linesHangar.drones.removeLast()
            factory.mannaHangar.drones.removeLast()
        }

        return finalReleaseOne
    }

    static func makeMakeAction(factory: SpriteFactory) -> SKAction {
        let w = factory.scene.size.width / 2
        let h = factory.scene.size.height / 2

        let makeOne = SKAction.run {
            SpriteFactory.count += 1
            var sprite = factory.arkonsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            factory.scene.addChild(sprite)

            sprite = factory.halfNeuronsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            factory.scene.addChild(sprite)

            sprite = factory.fullNeuronsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            factory.scene.addChild(sprite)

            sprite = factory.linesHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            factory.scene.addChild(sprite)

            sprite = factory.mannaHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            factory.scene.addChild(sprite)
        }

        return makeOne
    }

    static func selfTest(scene: SKScene) {
        phaseIndicator = SKColor.green

        let factory = SpriteFactory(
            scene: scene,
            thoraxFactory: SpriteFactory.makeFakeThorax(texture:),
            noseFactory: SpriteFactory.makeFakeNose(texture:))

        let wait = SKAction.wait(forDuration: 1.0 / 60.0)
        let waitABit = SKAction.repeat(wait, count: 100)
        let makeSequence = SKAction.sequence([wait, makeMakeAction(factory: factory)])
        let makeLots = SKAction.repeat(makeSequence, count: 300)

        let blue = SKAction.run { phaseIndicator = .blue }
        let spin = SKAction.sequence([wait, makeDestroyAction(factory: factory), makeMakeAction(factory: factory)])
        let spinABit = SKAction.repeat(spin, count: 100)
        let blueSpin = SKAction.sequence([spinABit, blue])

        let destroySequence = SKAction.sequence([wait, makeDestroyAction(factory: factory)])
        let destroyLots = SKAction.repeat(destroySequence, count: 300)

        let finalReleaseSequence = SKAction.sequence([wait, makeFinalReleaseAction(factory: factory)])
        let finalReleaseLots = SKAction.repeat(finalReleaseSequence, count: 300)

        let outline = SKAction.sequence([
            waitABit, makeLots, blueSpin, waitABit, spinABit, waitABit, destroyLots, finalReleaseLots
        ])

        scene.run(outline)
    }
}
