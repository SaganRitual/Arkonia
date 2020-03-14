import SpriteKit

struct DronePrototype {
    var alpha: CGFloat
    var color: SKColor
    var colorBlendFactor: CGFloat
    var zPosition: CGFloat
    var zRotation: CGFloat
}

class SpritePool {
    let atlas: SKTextureAtlas
    let parentSKNode: SKNode?
    var parkedDrones: [SKSpriteNode]
    var prototype: DronePrototype
    var texture: SKTexture
    let userDataKey: SpriteUserDataKey?

    init(
        _ atlasName: String,
        _ textureName: String,
        _ parentSKNode: SKNode?,
        _ poolCapacity: Int,
        _ prototype: DronePrototype,
        _ userDataKey: SpriteUserDataKey?
    ) {
        self.atlas = SKTextureAtlas(named: atlasName)
        self.texture = atlas.textureNamed(textureName)
        self.parentSKNode = parentSKNode
        self.parkedDrones = []
        self.parkedDrones.reserveCapacity(poolCapacity)
        self.prototype = prototype
        self.userDataKey = userDataKey
    }

    func attachSprite(_ sprite: SKSpriteNode, useCustomPortal: Bool = false) {
        guard useCustomPortal else {
            parentSKNode!.addChild(sprite)
            return
        }

        guard let customPortal = sprite.getKeyField(userDataKey!, require: false) as? SKSpriteNode
            else { fatalError() }

        customPortal.addChild(sprite)
    }

    func getDrone() -> SKSpriteNode {
        if parkedDrones.isEmpty {
            parkedDrones.append(SKSpriteNode(texture: self.texture))
        }

        guard let drone = parkedDrones.popLast() else { fatalError() }

        if drone.getKeyField(.uuid, require: false) as? String == nil {
            if drone.userData == nil { drone.userData = [:] }
            drone.userData![SpriteUserDataKey.uuid] = UUID().uuidString

            Debug.log(level: 100) {
                (drone.getKeyField(.uuid, require: false) as? String)!
            }
        }

        return drone
    }

    func makeSprite(_ name: String?) -> SKSpriteNode {
        let drone = getDrone()
        return makeSprite(with: drone, name)
    }

    func makeSprite(with drone: SKSpriteNode, _ name: String?) -> SKSpriteNode {
//        drone.alpha = prototype.alpha
        drone.color = .purple//prototype.color
        drone.colorBlendFactor = prototype.colorBlendFactor
        drone.name = name
        drone.zPosition = prototype.zPosition
        drone.zRotation = prototype.zRotation
        return drone
    }

    func releaseSprite(_ sprite: SKSpriteNode) {
        skRelease(sprite)
        parkedDrones.append(sprite)
    }

    func skRelease(_ sprite: SKSpriteNode) {
        sprite.removeAllActions()
        sprite.removeFromParent()
    }
}

class ThoraxPool: SpritePool {
    var netDisplayPortals = [SKSpriteNode]()
    var halfNeuronDisplayPortals = [SKSpriteNode]()
    var parkedDronesWithNetDisplay = [SKSpriteNode]()

    override init(
        _ atlasName: String,
        _ textureName: String,
        _ parentSKNode: SKNode?,
        _ poolCapacity: Int,
        _ prototype: DronePrototype,
        _ userDataKey: SpriteUserDataKey?   // Unused; keep it for the override
    ) {
        super.init(atlasName, textureName, parentSKNode, poolCapacity, prototype, .stepper)
        setupNetDisplayPortals()
    }

    override func getDrone() -> SKSpriteNode {
        if let netDisplayPortal = netDisplayPortals.popLast(),
            let halfNeuronDisplayPortal = halfNeuronDisplayPortals.popLast()
        {
            let drone = super.getDrone()
            drone.userData?[SpriteUserDataKey.net9Portal] = netDisplayPortal
            drone.userData?[SpriteUserDataKey.netHalfNeuronsPortal] = halfNeuronDisplayPortal
            return drone
        }

        if let readyDrone = parkedDronesWithNetDisplay.popLast() { return readyDrone }
        else { return super.getDrone() }
    }

    override func releaseSprite(_ sprite: SKSpriteNode) {
        if sprite.getKeyField(.net9Portal, require: false) == nil {
            skRelease(sprite)
            parkedDrones.append(sprite)
            Debug.log(level: 101) { "release to plain drones array" }
            return
        }

        guard let fullNeuronPortal = sprite.getKeyField(.net9Portal) as? SKSpriteNode,
            let halfNeuronPortal = sprite.getKeyField(.netHalfNeuronsPortal) as? SKSpriteNode
        else { fatalError() }

        fullNeuronPortal.removeAllChildren()
        halfNeuronPortal.removeAllChildren()

        skRelease(sprite)
        parkedDronesWithNetDisplay.append(sprite)
        Debug.log(level: 101) { "release to net display drones array" }
    }

    func setupNetDisplayPortals() {

        GriddleScene.shared.enumerateChildNodes(withName: "net_9portal*") { node, _ in
            guard let portal = node as? SKSpriteNode else { fatalError() }
            self.netDisplayPortals.append(portal)
        }

        GriddleScene.shared.enumerateChildNodes(withName: "net_9portal_halfNeurons*") { node, _ in
            guard let portal = node as? SKSpriteNode else { fatalError() }
            self.halfNeuronDisplayPortals.append(portal)
        }

        self.netDisplayPortals.sort { $0.name! < $1.name! }
        self.halfNeuronDisplayPortals.sort { $0.name! < $1.name! }
    }
}
