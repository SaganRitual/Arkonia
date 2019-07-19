import SpriteKit

class Karamba: HasContactDetector {
    var contactDetector: ContactDetectorProtocol?
    let core: Arkon
    var maneuvers: Maneuvers!
    let metabolism: MetabolismProtocol
    var motionSelector = 0
    var senseLoader: SenseLoader!

    var nose: SKSpriteNode { return core.nose }
    var pBody: SKPhysicsBody { return core.sprite.physicsBody! }
    var sprite: SKSpriteNode { return core.sprite }

    init(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) {
//        let core = Arkon(
            parentBiases: parentWeights, parentWeights: parentWeights, layers: layers
        )

        let spritePhysicsBody = SKPhysicsBody(circleOfRadius: core.sprite.size.width / 2)

        spritePhysicsBody.categoryBitMask = PhysicsBitmask.arkonBody.rawValue
        spritePhysicsBody.collisionBitMask = PhysicsBitmask.arkonBody.rawValue

        spritePhysicsBody.contactTestBitMask =
            PhysicsBitmask.arkonBody.rawValue |
            PhysicsBitmask.mannaBody.rawValue

        spritePhysicsBody.mass = 1
        contactDetector = ContactDetector()

        let nosePhysicsBody = SKPhysicsBody(circleOfRadius: core.nose.size.width * 2)

        nosePhysicsBody.categoryBitMask = PhysicsBitmask.arkonSenses.rawValue
        nosePhysicsBody.collisionBitMask = 0

        nosePhysicsBody.contactTestBitMask =
            PhysicsBitmask.arkonBody.rawValue |
            PhysicsBitmask.mannaBody.rawValue

        nosePhysicsBody.mass = 0.1
        nosePhysicsBody.pinned = true

        maneuvers = nil

        core.sprite.physicsBody = spritePhysicsBody
        core.nose.physicsBody = nosePhysicsBody

        metabolism = Metabolism(spritePhysicsBody)

        self.core = core
        sprite.userData![SpriteUserDataKey.karamba] = self

        contactDetector!.isReadyForPhysics = true
    }

    deinit {
        maneuvers = nil
    }
}

extension Karamba {

    static func brainlyManeuverStart(sprite thorax: SKSpriteNode, metabolism: MetabolismProtocol) {
//        print("bm", thorax.arkon.selectoid.fishNumber)
//        let motorOutputs = thorax.arkon.net.getMotorOutputs(sensoryInputs)
//
//        let workItem = DispatchWorkItem {
//            brainlyManeuverEnd(sprite: thorax, metabolism: metabolism, motorOutputs: motorOutputs)
//        }
//
//        thorax.arkon.netQueue.async(execute: workItem)

//        var motorOutputs = [Double]()
//        let workAction = SKAction.run({
//            let sensoryInputs = thorax.arkon.stimulus()
//            motorOutputs = thorax.arkon.net.getMotorOutputs(sensoryInputs)
//        }, queue: thorax.arkon.netQueue)
//
//        thorax.run(workAction) {
//            brainlyManeuverEnd(sprite: thorax, metabolism: metabolism, motorOutputs: motorOutputs)
//        }

        var netSignal = KarambaNetSignal()
        netSignal.go(karamba: thorax.karamba)
    }

    static func brainlyManeuverEnd(sprite: SKSpriteNode, metabolism: Metabolism, motorOutputs: [Double]) {
        guard let karamba = sprite.optionalKaramba else { return }
        karamba.maneuvers = Maneuvers(energySource: metabolism)
        let maneuvers = sprite.karamba.maneuvers!
        let action = maneuvers.selectActionPrimitive(sprite: sprite, motorOutputs: motorOutputs)
        let wait = SKAction.wait(forDuration: 0.01)
        let sequence = SKAction.sequence([wait, action])
        sprite.run(sequence) { onePass(sprite: sprite, metabolism: metabolism) }
    }

        static func onePass(sprite thorax: SKSpriteNode, metabolism: MetabolismProtocol) {
            let nose = (thorax.children[0] as? Nose)!

    //        print("o2a", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel, terminator: "")
            let oxygenCost: TimeInterval = thorax.karamba.core.age < TimeInterval(5) ? 0 : 1
            metabolism.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)
    //        print("o2b", metabolism.oxygenLevel)

            guard metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0 else {
    //            print("ap", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel)
                thorax.karamba.core.apoptosize()
                return
            }

            // 10% entropy
            let spawnCost = EnergyReserve.startingEnergyLevel * 1.10

            if metabolism.spawnReserves.level >= spawnCost {
                metabolism.withdrawFromSpawn(spawnCost)

                let biases = thorax.karamba.core.net.biases
                let weights = thorax.karamba.core.net.weights
                let layers = thorax.karamba.core.net.layers
                let waitAction = SKAction.wait(forDuration: 0.02)
                let spawnAction = SKAction.run {
                    Karamba.spawn(parentBiases: biases, parentWeights: weights, layers: layers)
                }

                let sequence = SKAction.sequence([waitAction, spawnAction])
                Arkon.arkonsPortal!.run(sequence) {
                    thorax.karamba.core.selectoid.cOffspring += 1
                    World.shared.registerCOffspring(thorax.karamba.core.selectoid.cOffspring)
                }

            }

            let ef = metabolism.fungibleEnergyFullness
            nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

            let baseColor: Int
            if thorax.karamba.core.selectoid.fishNumber < 10 {
                baseColor = 0xFF_00_00
            } else {
                baseColor = (metabolism.spawnEnergyFullness > 0) ?
                    Arkon.brightColor : Arkon.standardColor
            }

            let four: CGFloat = 4
            thorax.color = ColorGradient.makeColorMixRedBlue(
                baseColor: baseColor,
                redPercentage: metabolism.spawnEnergyFullness,
                bluePercentage: max((four - CGFloat(thorax.karamba.core.age)) / four, 0.0)
            )

            thorax.colorBlendFactor = thorax.karamba.metabolism.oxygenLevel

            brainlyManeuverStart(sprite: thorax, metabolism: metabolism)
        }

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Karamba {

        let newKaramba = Karamba(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        newKaramba.sprite.position = Arkon.arkonsPortal!.getRandomPoint()
        newKaramba.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

        newKaramba.contactDetector!.contactResponder =
            ContactResponder(ownerKaramba: newKaramba)

        newKaramba.contactDetector!.senseResponder = SenseResponder()

        onePass(sprite: newKaramba.sprite, metabolism: newKaramba.metabolism)

        return newKaramba
    }

    func tick() {
        metabolism.tick()
        core.tick()
    }
}
