import Foundation
import SpriteKit

class SpriteHangar {
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
    var phaseIndicator = SKColor.green

    init(scene: SKScene) {
        self.scene = scene

        arkonsHangar = SpriteHangar("Arkons", "spark-aluminum-large")
        fullNeuronsHangar = SpriteHangar("Neurons", "neuron-plain")
        halfNeuronsHangar = SpriteHangar("Neurons", "neuron-plain-half")
        linesHangar = SpriteHangar("Line", "line")
        mannaHangar = SpriteHangar("Manna", "manna")
    }
}

extension SpriteFactory {
    func makeDestroyAction() -> SKAction {
        let destroyOne = SKAction.run {
            self.count -= 1

            (0..<5).forEach { _ in
                guard let doomed = self.scene.children.randomElement() as? SKSpriteNode
                    else { preconditionFailure() }

                doomed.removeFromParent()
                doomed.color = self.phaseIndicator
                doomed.colorBlendFactor = 1
            }
        }

        return destroyOne
    }

    func makeFinalReleaseAction() -> SKAction {
        let finalReleaseOne = SKAction.run {
            self.arkonsHangar.drones.removeLast()
            self.fullNeuronsHangar.drones.removeLast()
            self.halfNeuronsHangar.drones.removeLast()
            self.linesHangar.drones.removeLast()
            self.mannaHangar.drones.removeLast()
        }

        return finalReleaseOne
    }

    func makeMakeAction() -> SKAction {
        let w = scene.size.width / 2
        let h = scene.size.height / 2

        let makeOne = SKAction.run {
            self.count += 1
            var sprite = self.arkonsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            self.scene.addChild(sprite)

            sprite = self.halfNeuronsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            self.scene.addChild(sprite)

            sprite = self.fullNeuronsHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            self.scene.addChild(sprite)

            sprite = self.linesHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            self.scene.addChild(sprite)

            sprite = self.mannaHangar.makeSprite()
            sprite.position = CGPoint(x: CGFloat.random(in: -w..<w), y: CGFloat.random(in: -h..<h))
            self.scene.addChild(sprite)
        }

        return makeOne
    }

    func selfTest() {
        let wait = SKAction.wait(forDuration: 1.0 / 60.0)
        let waitABit = SKAction.repeat(wait, count: 100)
        let makeSequence = SKAction.sequence([wait, makeMakeAction()])
        let makeLots = SKAction.repeat(makeSequence, count: 300)

        let blue = SKAction.run { self.phaseIndicator = .blue }
        let spin = SKAction.sequence([wait, makeDestroyAction(), makeMakeAction()])
        let spinABit = SKAction.repeat(spin, count: 100)
        let blueSpin = SKAction.sequence([spinABit, blue])

        let destroySequence = SKAction.sequence([wait, makeDestroyAction()])
        let destroyLots = SKAction.repeat(destroySequence, count: 300)

        let finalReleaseSequence = SKAction.sequence([wait, makeFinalReleaseAction()])
        let finalReleaseLots = SKAction.repeat(finalReleaseSequence, count: 300)

        let outline = SKAction.sequence([
            waitABit, makeLots, blueSpin, waitABit, spinABit, waitABit, destroyLots, finalReleaseLots
        ])

        self.scene.run(outline)
    }
}
