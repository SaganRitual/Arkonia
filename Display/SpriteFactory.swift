import Foundation
import SpriteKit

protocol HangarProtocol {
    var atlas: SKTextureAtlas? { get }
    var drones: [SKSpriteNode] { get set }
}

protocol MultiTextureHangar: HangarProtocol {
    var textures: [NeuronsHangar.NeuronColor: SKTexture] { get }
}

protocol SingleTextureHangar: HangarProtocol {
    var texture: SKTexture { get }
    func makeSprite() -> SKSpriteNode
}

class SpriteHangar: SingleTextureHangar {
    let atlas: SKTextureAtlas?
    var drones = [SKSpriteNode]()
    let texture: SKTexture

    init(_ texture: SKTexture) { self.atlas = nil; self.texture = texture }

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

class NeuronsHangar: MultiTextureHangar {
    enum NeuronColor { case blue, green, orange }

    let atlas: SKTextureAtlas?
    var drones = [SKSpriteNode]()
    var textures = [NeuronColor: SKTexture]()

    init(_ atlasName: String, _ textureNames: [String]) {
        atlas = SKTextureAtlas(named: atlasName)
        textures = textureNames.map { atlas!.textureNamed($0) }
    }

    func makeSprite(color: NeuronColor) -> SKSpriteNode {
        if let readyDrone = drones.first(where: { drone in
            switch drone.texture.named {
                case
            }
            sprite in sprite.parent == nil &&  }) {
            return readyDrone
        }

        let newSprite = SKSpriteNode(texture: texture)
        drones.append(newSprite)
        return newSprite
    }
}

class SpriteFactory {
    let arkonsHangar: SpriteHangar
    let linesHangar: SpriteHangar
    let mannaHangar: SpriteHangar
    let neuronsHangar: NeuronsHangar

    init() {
        arkonsHangar = SpriteHangar("Arkons", "spark-aluminum-large")
        mannaHangar = SpriteHangar("Manna", "manna")

        neuronsHangar = NeuronsHangar("Neurons", [
            "neuron-blue", "neuron-green-half", "neuron-orange-half"
        ])
    }

    func makeLineSprite() -> SKSpriteNode { return linesHangar.makeSprite() }
}
