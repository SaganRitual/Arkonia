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
    var userDataKey: SpriteUserDataKey?

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

        let customPortal = (sprite.getKeyField(userDataKey!, require: false) as? SKSpriteNode)!
        customPortal.addChild(sprite)
    }

    func getDrone() -> SKSpriteNode {
        if parkedDrones.isEmpty {
            parkedDrones.append(SKSpriteNode(texture: self.texture))
        }

        let drone = (parkedDrones.popLast())!

        return drone
    }

    func makeSprite(_ name: ArkonName?) -> SKSpriteNode {
        let drone = getDrone()
        return makeSprite(with: drone, name)
    }

    func makeSprite(with drone: SKSpriteNode, _ name: ArkonName?) -> SKSpriteNode {
//        drone.alpha = prototype.alpha
        drone.color = .purple//prototype.color
        drone.colorBlendFactor = prototype.colorBlendFactor
        drone.name = "\(name!.nametag)(\(name!.setNumber))"
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

    init(
        _ atlasName: String,
        _ textureName: String,
        _ parentSKNode: SKNode?,
        _ poolCapacity: Int,
        _ prototype: DronePrototype
    ) {
        super.init(atlasName, textureName, parentSKNode, poolCapacity, prototype, nil)
        setupNetDisplayPortals()
    }

    override func getDrone() -> SKSpriteNode {
        Debug.log(level: 172) { "getDrone.0" }
        if let netDisplayPortal = netDisplayPortals.popLast(),
            let halfNeuronDisplayPortal = halfNeuronDisplayPortals.popLast()
        {
            Debug.log(level: 172) { "getDrone.1" }
            let drone = super.getDrone()
            drone.userData = [:]
            drone.userData![SpriteUserDataKey.net9Portal] = netDisplayPortal
            drone.userData![SpriteUserDataKey.netHalfNeuronsPortal] = halfNeuronDisplayPortal
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

        let fullNeuronPortal = (sprite.getKeyField(.net9Portal) as? SKSpriteNode)!
        let halfNeuronPortal = (sprite.getKeyField(.netHalfNeuronsPortal) as? SKSpriteNode)!

        fullNeuronPortal.removeAllChildren()
        halfNeuronPortal.removeAllChildren()

        skRelease(sprite)
        parkedDronesWithNetDisplay.append(sprite)
        Debug.log(level: 101) { "release to net display drones array" }
    }

    func setupNetDisplayPortals() {
        Debug.log(level: 163) { "setupNetDisplayPortals" }

        ArkoniaScene.netPortal.enumerateChildNodes(withName: "net_9portal_full*") { node, _ in
            let portal = (node as? SKSpriteNode)!
            self.netDisplayPortals.append(portal)
        }

        ArkoniaScene.netPortalHalfNeurons.enumerateChildNodes(withName: "net_9portal_half*") { node, _ in
            let portal = (node as? SKSpriteNode)!
            self.halfNeuronDisplayPortals.append(portal)
        }

        self.netDisplayPortals.sort { $0.name! < $1.name! }
        self.halfNeuronDisplayPortals.sort { $0.name! < $1.name! }
    }
}
