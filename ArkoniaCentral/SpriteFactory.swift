import Foundation
import SpriteKit

class SpriteHangar: SpriteHangarProtocol {
    let atlas: SKTextureAtlas?
    var drones = [SKSpriteNode]()
    var texture: SKTexture

    init(_ atlasName: String, _ textureName: String) {
        atlas = SKTextureAtlas(named: atlasName)
        texture = atlas!.textureNamed(textureName)
    }

    func makeSprite() -> SKSpriteNode {
        if let readyDrone = drones.first(where: { sprite in sprite.parent == nil }) {
            return readyDrone
        }

        let newSprite = SKSpriteNode(texture: texture)

        drones.append(newSprite)
        return newSprite
    }
}

class SpriteFactory {
    let arkonsHangar: SpriteHangar
    let fullNeuronsHangar: SpriteHangar
    let halfNeuronsHangar: SpriteHangar
    let linesHangar: SpriteHangar
    let mannaHangar: SpriteHangar
    let scene: SKScene
    var count = 0

    init(scene: SKScene) {
        self.scene = scene

        arkonsHangar = SpriteHangar("Arkons", "spark-outline-large")
        fullNeuronsHangar = SpriteHangar("Neurons", "neuron-plain")
        halfNeuronsHangar = SpriteHangar("Neurons", "neuron-plain-half")
        linesHangar = SpriteHangar("Line", "line")
        mannaHangar = SpriteHangar("Manna", "manna")
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

        let factory = SpriteFactory(scene: scene)
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
