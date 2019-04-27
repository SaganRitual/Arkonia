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

    static func makeDrone(geneticParentFishNumber f: Int?, geneticParentGenome g: [GeneProtocol]?) {
        Karamba.backlogCount += 1

        ArkonFactory.karambaSerializerQueue.async {
            KarambaDarkOps.darkOps(f, g)
            Karamba.backlogCount -= 1
        }
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

        if let cb = contactedBodies, cb.isEmpty == false {
            calorieTransfer() }
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
