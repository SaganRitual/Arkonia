import Foundation
import SpriteKit

extension CGFloat { static let tau = 2 * CGFloat.pi }

class Karamba: SKSpriteNode {
    let gParentFishNumber: Int?
    let gParentGenome: [GeneProtocol]?

    init(_ gParentFishNumber: Int?, _ gParentGenome: [GeneProtocol]?) {
        self.gParentGenome = gParentGenome
        self.gParentFishNumber = gParentFishNumber

        super.init(
            texture: ArkonCentralLight.topTexture,
            color: .green,
            size: ArkonCentralLight.topTexture!.size()
        )

        super.alpha = 0
    }

    func launch() {
        let action = SKAction.run(launch_, queue: ArkonFactory.karambaSerializerQueue)
        PortalServer.shared.arkonsPortal.run(action)
    }

    private func launch_() {
        let parentGenome = gParentGenome ?? ArkonFactory.getAboriginalGenome()

        guard let arkon = ArkonFactory.shared.makeArkon(
            parentFishNumber: gParentFishNumber, parentGenome: parentGenome
        ) else { return }    // Arkon died due to non-viable genome

        // Just for debugging, so I can see who's doing what
        World.shared.population.getArkon(for: gParentFishNumber)?.sprite.color = .yellow

        // Save until I'm ready to clean it all up
        self.arkon = arkon
        setUserData(key: .arkon, to: arkon)

        name = "arkon_\(arkon.fishNumber)"
        color = .green
        colorBlendFactor = 1.0

        let comeIntoExistence = SKAction.run {
            let senseOrgan = SKNode()
            self.addChild(senseOrgan)

            let properSensesBodyRadius: CGFloat = self.size.radius * 1.5
            let sensesPBody = SKPhysicsBody(circleOfRadius: properSensesBodyRadius)

            sensesPBody.friction = 1.0
            sensesPBody.isDynamic = false
            sensesPBody.mass = 0.0
            sensesPBody.collisionBitMask = 0
            sensesPBody.allowsRotation = false
            sensesPBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
            sensesPBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue
            senseOrgan.physicsBody = sensesPBody

            let properBodyRadius: CGFloat = self.size.radius * 0.5
            let pBody = SKPhysicsBody(circleOfRadius: properBodyRadius)

            pBody.friction = 1.0
            pBody.isDynamic = false
            pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
            pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
            pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
            pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.dragField.rawValue

            self.physicsBody = pBody
        }

        let lunch = SKAction.run { self.arkon!.launch(sprite: self) }
        let sequence = SKAction.sequence([comeIntoExistence, lunch])

        zRotation = CGFloat.random(in: 0..<CGFloat.tau)
        apparate()
        run(sequence) {
            hardBind(self.physicsBody).isDynamic = true
            hardBind(self.children[0].physicsBody).isDynamic = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Karamba {
    func apparate() { PortalServer.shared.arkonsPortal.addChild(self) }

    static func createDrones(_ cKarambas: Int) {
        (0..<cKarambas).forEach { _ in
            let k = Karamba(nil, nil)
            let w = PortalServer.shared.arkonsPortal.frame.size.width
            let h = PortalServer.shared.arkonsPortal.frame.size.height

            let xRange = -w..<w
            let yRange = -h..<h
            k.position = CGPoint.random(xRange: xRange, yRange: yRange)
            k.launch()
        }
    }

    func lastMinuteBusiness() {
        guard let a = self.arkon else { return }
        if a.scheduledActions.isEmpty { return }

        defer { a.scheduledActions.removeAll() }
        run(SKAction.sequence(a.scheduledActions))
    }

    static var firstHotArkon = false
    func response(motorNeuronOutputs: [Double]) {
        let m = motorNeuronOutputs

//        let truncked = m.map { String(format: "% -.5e", $0) }
//        print("outputs", truncked)

        if m.reduce(0, +) == 0 { color = .darkGray } else {
            color = .green
            if !Karamba.firstHotArkon {
                Karamba.firstHotArkon = true
                Display.shared.display(
                    arkon!.signalDriver.kNet, portal: PortalServer.shared.netPortal
                )
            }
        }

        let actionPrimitive = ActionPrimitive.getMotionActions(sprite: self, motorOutputs: m)
        run(actionPrimitive)
    }
}
