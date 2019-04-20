import Foundation
import SpriteKit

extension CGFloat { static let tau = 2 * CGFloat.pi }

class Karamba: SKSpriteNode {
    var arkon: Arkon!
    var contactedBodies: [SKPhysicsBody]?
    let geneticParentFishNumber: Int?
    let geneticParentGenome: [GeneProtocol]?
    var isAlive = false
    var metabolism = Metabolism()
    var previousPosition = CGPoint.zero
    var readyForPhysics = false
    var isReadyForTick = false
    var sensedBodies: [SKPhysicsBody]?
    var sensoryInputs = [Double]()
    var senseLoader: SenseLoader!

    init(_ geneticParentFishNumber: Int?, _ geneticParentGenome: [GeneProtocol]?) {
        self.geneticParentGenome = geneticParentGenome
        self.geneticParentFishNumber = geneticParentFishNumber

        super.init(
            texture: ArkonCentralLight.topTexture,
            color: (geneticParentFishNumber == nil) ? .cyan : .yellow,
            size: ArkonCentralLight.topTexture!.size()
        )
    }

    deinit {
//        print(" deinit", arkon?.fishNumber ?? -42)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Convenience & readability

extension Karamba {
    var nose: KNoseNode { return hardBind(children[0] as? KNoseNode) }
    var pBody: SKPhysicsBody { return physicsBody! }
//    var portal: SKSpriteNode { return PortalServer.shared.arkonsPortal }
    var scab: Arkon { return hardBind(arkon) }
//    var sensor: SKPhysicsBody { return hardBind(nose.physicsBody) }

    var isInBounds: Bool {
        let scene = hardBind(Display.shared.scene)
        let portal = hardBind(scene.childNode(withName: "arkons_portal") as? SKSpriteNode)
        let relativeToPortal = portal.convert(frame.origin, to: portal.parent!)

        let w = size.width * portal.xScale
        let h = size.height * portal.yScale
        let scaledSize = CGSize(width: w, height: h)
        let arkonRectangle = CGRect(origin: relativeToPortal, size: scaledSize)

        // Remember: get the scene frame rather than the portal frame because
        // that's how big the portal's children think the portal is. We can't
        // use the portal's frame, because it is doing its own thing due to scaling.
        return portal.frame.contains(arkonRectangle)
    }
}

// MARK: Construction & setup

extension Karamba {
    static var backlogCount = 0
    // swiftlint:disable function_body_length
    private static func darkOps(
        _ geneticParentFishNumber: Int?, _ geneticParentGenome: [GeneProtocol]?
    ) {
        defer {
            Karamba.backlogCount -= 1
        }
        let nose = KNoseNode(
            texture: ArkonCentralLight.topTexture,
            color: .green,
            size: ArkonCentralLight.topTexture!.size()
        )

        nose.name = "nose_awaiting_fish_number"
        nose.setScale(0.5)
        nose.color = .blue
        nose.colorBlendFactor = 1.0
        nose.zPosition = ArkonCentralLight.vArkonZPosition + 1

        let arkon = Karamba(geneticParentFishNumber, geneticParentGenome)
        arkon.colorBlendFactor = 1.0
        arkon.zPosition = ArkonCentralLight.vArkonZPosition

        let (pBody, nosePBody) = makePhysicsBodies(arkonRadius: arkon.size.radius)
        arkon.metabolism.pBody = pBody

        let parentGenome = geneticParentGenome ?? ArkonFactory.getAboriginalGenome()

        guard let scab = ArkonFactory.shared.makeArkon(
            parentFishNumber: geneticParentFishNumber, parentGenome: parentGenome
        ) else { return }    // Arkon died due to non-viable genome

        arkon.arkon = scab
        arkon.name = "arkon_\(scab.fishNumber)"
        nose.name = "nose_\(scab.fishNumber)"
        arkon.setScale(ArkonFactory.scale)

        let scene = hardBind(Display.shared.scene)
        let portal = hardBind(scene.childNode(withName: "arkons_portal") as? SKSpriteNode)
        let xRange = -portal.frame.size.width..<portal.frame.size.width
        let yRange = -portal.frame.size.height..<portal.frame.size.height
        arkon.position = CGPoint.random(xRange: xRange, yRange: yRange)
        arkon.zRotation = CGFloat.random(in: 0..<CGFloat.tau)

        World.shared.populationChanged = true

        // The physics engine becomes unhappy if we add the arkon to the portal
        // in the wrong phase of the display cycle, which happens because we're
        // running all this setup on a work queue rather than in the main display
        // update. So instead of adding in this context, we hand off an action to
        // the portal and let him add us when it's safe.
        let action = SKAction.run {
//            print("adding", arkon.scab.fishNumber)
            portal.addChild(arkon)
            arkon.addChild(nose)

            // Surprisingly, the physics engine also becomes unhappy if we add
            // the physics bodies before we add their owning nodes to the scene.
            arkon.physicsBody = pBody
            nose.physicsBody = nosePBody
//
            arkon.senseLoader = SenseLoader(arkon)
//
            nosePBody.pinned = true // It wouldn't do to leave our senses behind
//            print("doa")
        }

        portal.run(action, completion: {
            Karamba.backlogCount -= 1
            arkon.isReadyForTick = true
            arkon.isAlive = true
        })

//        print("doe")
    }
    // swiftlint:enable function_body_length

    static func makeDrone(geneticParentFishNumber f: Int?, geneticParentGenome g: [GeneProtocol]?) {
        Karamba.backlogCount += 1
        ArkonFactory.karambaSerializerQueue.async {
            darkOps(f, g)
        }
    }

    static func makePhysicsBodies(arkonRadius: CGFloat) -> (SKPhysicsBody, SKPhysicsBody) {
        let sensesPBody = SKPhysicsBody(circleOfRadius: arkonRadius * 1.5)
        let edible =
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue |
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        sensesPBody.mass = 0.1
        sensesPBody.allowsRotation = false
        sensesPBody.collisionBitMask = 0
        sensesPBody.contactTestBitMask = edible
        sensesPBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue

        let pBody = SKPhysicsBody(circleOfRadius: arkonRadius / 14)

        pBody.mass = 1
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = edible
        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = 0

        return (pBody, sensesPBody)
    }
}

extension Karamba {
    func apoptosize() {
//        print("apop", scab.fishNumber)
        isAlive = false
        arkon = nil
        contactedBodies = nil           // So I won't go through my next
        sensedBodies = nil              // tick thinking I have physics to take care of
        nose.physicsBody = nil
        metabolism.pBody = nil
        physicsBody = nil
        removeAllChildren()
        removeAllActions()
//        let apopReportS = SKAction.run {
//            print("apopReportS", self.name ?? "foogie") }
//        let remove = SKAction.removeFromParent()
//        let sequence = SKAction.sequence([apopReportS, remove])
//        run(sequence, completion: { print("apopReportE", self.name ?? "boogie") })
        removeFromParent()
    }

    enum CombatStatus { case losing(Karamba), surviving, winning(Karamba)  }
    enum HerbivoreStatus { case goingHungry, grazing }

    func calorieTransfer() {
        let combatStatus = combat()

        var opponent: Karamba!
        switch combatStatus {
        case let .losing(k):  opponent = k; return
        case let .winning(k): opponent = k
        case .surviving:      break
        }

        if let victim = opponent { eatArkon(victim) }

        let herbivoreStatus = graze()
        if herbivoreStatus == .grazing { eatManna() }
    }

    static func createDrones(_ cKarambas: Int) {
        (0..<cKarambas).forEach { _ in
            Karamba.makeDrone(geneticParentFishNumber: nil, geneticParentGenome: nil)
        }
    }

    func response(motorNeuronOutputs: [Double]) {
        let m = motorNeuronOutputs
        let actionPrimitive = selectActionPrimitive(arkon: self, motorOutputs: m)
        run(actionPrimitive)
    }

    func tick() {
        // Because the physics engine gets cranky if we try to add physics
        // bodies to our nodes before we add the nodes to the scene, we have
        // to allow for the scene to start ticking us before we're fully ready
        // (that is, before we've added the physics bodies). So don't do anything
        // until isAlive is set.
        guard isAlive else { return }

        readyForPhysics = true
        isReadyForTick = false

        guard isInBounds && pBody.mass > 0.1 && metabolism.oxygenLevel > 0 else {
            apoptosize()
            return
        }

        alpha = pBody.mass * 4
        nose.colorBlendFactor = metabolism.oxygenLevel

        if let cb = contactedBodies, cb.isEmpty == false { calorieTransfer() }
//        print("h", metabolism.health, "m", pBody.mass)
        if pBody.mass > 1.0 {
            let a = hardBind(arkon)
            Karamba.makeDrone(geneticParentFishNumber: a.fishNumber, geneticParentGenome: a.genome)
            metabolism.giveBirth()
        }

        // Coincidentally, in Arkonia, we measure distance and volume using
        // the same units.
        metabolism.inhale(position.distance(to: previousPosition) / (size.width / 2))
        metabolism.tick()

        previousPosition = position

        let stimulusAction = SKAction.run { [weak self] in self?.stimulus() }
        let netSignalAction = SKAction.run(driveNetSignal, queue: ArkonFactory.karambaStimulusQueue)
        let responseAction = SKAction.run { [weak self] in self?.response() }
        let sequence = SKAction.sequence([stimulusAction, netSignalAction, responseAction])
        run(sequence) { self.isReadyForTick = true }
    }
}

extension Karamba: ManeuverProtocol {
    override var scene: SKScene { return hardBind(Display.shared.scene) }
}
