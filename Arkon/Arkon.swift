import Foundation
import SpriteKit

class Arkon {
    static private var lifespanInTicks = 60

    let birthday: TimeInterval
    private var canHaveMoreOffspring = true
    private var destructAction: SKAction!
    let fishNumber: Int
    private let fNet: FNet
    private let genome: Genome
    private var hasGivenBirth = false
    private var health = 3000.0
    private var isAlive = false
    var kNet: KNet!
    private var motorOutputs: MotorOutputs!
    private var portal: SKSpriteNode!
    private var previousPosition: CGPoint?
    private var previousTime: TimeInterval = 0
    let signalDriver: KSignalDriver
    var sprite: SKSpriteNode!
    private var tickAction: SKAction!

    private var isHealthy: Bool { return health > 0 }

    private var isInBounds: Bool {
        let relativeToPortal = portal.convert(sprite.frame.origin, to: portal.parent!)

        let w = sprite.size.width * portal.xScale
        let h = sprite.size.height * portal.yScale
        let scaledSize = CGSize(width: w, height: h)

        let arkonRectangle = CGRect(origin: relativeToPortal, size: scaledSize)

        // Remember: get the scene frame rather than the portal frame because
        // that's how big the portal's children think the portal is. We can't
        // use the portal's frame, because it is doing its own thing due to scaling.
        return portal.frame.contains(arkonRectangle)
    }

    var myAge: TimeInterval { return Display.shared.currentTime - self.birthday }

    init?(genome: Genome, fNet: FNet, portal: SKSpriteNode) {
        self.fishNumber = ArkonCentralDark.selectionControls.theFishNumber
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.birthday = Display.shared.currentTime

        self.portal = portal

        self.genome = genome
        self.fNet = fNet
        self.signalDriver = KSignalDriver(idNumber: self.fishNumber, fNet: fNet)

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: Array.init(
                repeating: 0, count: ArkonCentralDark.selectionControls.cSenseNeurons
            )
        )

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle, unless, of course, we didn't
        // survive the test signal.

        if !arkonSurvived { return nil }
    }

    func launch(parentFishNumber: Int?) {
        let sprite = Arkon.setupSprite(fishNumber)
        self.motorOutputs = MotorOutputs(sprite)

        self.sprite = sprite

        let x = Int.random(in: Int(-portal.frame.size.width)..<Int(portal.frame.size.width))
        let y = Int.random(in: Int(-portal.frame.size.height)..<Int(portal.frame.size.height))
        self.sprite.position = CGPoint(x: x, y: y)

        portal.addChild(sprite)

        self.sprite.userData = ["Arkon": self]  // Ref to self; we're on our own after birth

        self.destructAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.sprite?.userData?["Arkon"] = nil
                self?.sprite = nil
            },
            SKAction.removeFromParent()
        ])

        self.tickAction = SKAction.run(
            { [weak self] in self?.tick() }, queue: World.shared.dispatchQueue
        )

        self.sprite.run(self.tickAction)

        // If I have a parent (ie, I'm not in the aboriginal generation), tell my
        // parent that my birth is complete, so she can get up and run away from
        // predators now.
        guard let p = parentFishNumber else { return }
        Arkonery.reviveSpawner(fishNumber: p)
    }

    deinit {
//        print("Arkon(\(fishNumber)) deinit")
        self.sprite?.removeFromParent()

        // Decrement living count only if I am a living arkon, that is,
        // if I survived birth.
        if self.isAlive {
            World.shared.arkonery.cLivingArkons -= 1
            self.isAlive = false // Tidiness/superstition
        }
    }
}

// MARK: Guts

extension Arkon {

//    private func getDisplayAction(_ thrustVectors: [CGVector]) -> SKAction {
//        let fo1 = SKAction.fadeOut(withDuration: 0.05)
//        let fi2 = SKAction.fadeIn(withDuration: 0.05)
//
//        return SKAction.sequence([fo1, fi2])
//    }

    private func apoptosize() {
        sprite.removeAllActions()
        sprite.run(destructAction)
        sprite = nil
    }

    private func getThrustVectors(_ motorNeuronOutputs: [Double]) -> [CGVector] {
        var vectors = [CGVector]()

        for ss in stride(from: 0, to: motorNeuronOutputs.count, by: 2) {
            let xThrust = motorNeuronOutputs[ss]
            let yThrust = motorNeuronOutputs[ss + 1]
            vectors.append(CGVector(dx: xThrust, dy: yThrust))
        }

        return vectors
    }

    private func tick() {

        self.isAlive = true

        if self.sprite.userData == nil { preconditionFailure("Shouldn't happen; I'm desperate") }
        if !self.isInBounds || !self.isHealthy { apoptosize(); return }

        health -= 1.0 // Time ever marches on
        if health > 3000 {
            let nName = Foundation.Notification.Name.arkonIsBorn
            let nCenter = NotificationCenter.default
            var observer: NSObjectProtocol?

            observer = nCenter.addObserver(forName: nName, object: nil, queue: nil) {
                [weak self] (notification: Notification) in

                guard let myself = self else { return }
                guard let u = notification.userInfo as? [String: Int] else { return }
                guard let f = u["parentFishNumber"] else { return }

                if f == myself.fishNumber {
                    myself.sprite.run(myself.tickAction)
                    nCenter.removeObserver(observer!)
                }
            }

            World.shared.arkonery.spawn(parentID: self.fishNumber, parentGenome: self.genome)
            return  // I'm idle and vulnerable until I've finished giving birth
        }

        let rToOrigin = Double(hypotf(Float(-self.sprite.position.x), Float(-self.sprite.position.y)))
        precondition(rToOrigin >= 0)
        let θToOrigin = Double(atan2(self.sprite.position.y, self.sprite.position.x))

        health += 1000.0 / ((rToOrigin < 1) ? 1 : pow(rToOrigin, 1.2))
        var velocity = CGVector.zero
        let currentTime = Display.shared.currentTime

        if let previousPosition = self.previousPosition {
            let distance = previousPosition.distance(to: self.sprite.position)
            let elapsedTime = currentTime - previousTime
            let speed = distance / CGFloat(elapsedTime)
            velocity = previousPosition.velocity(toward: self.sprite.position, speed: speed)
        }

        previousPosition = self.sprite.position
        previousTime = currentTime

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: [rToOrigin, θToOrigin, Double(velocity.dx), Double(velocity.dy)]
        )

        precondition(arkonSurvived, "Should have died from test signal in init")

        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        let thrustVectors = getThrustVectors(motorNeuronOutputs)
        let motionAction = motorOutputs.getAction(thrustVectors)
//        let displayAction = getDisplayAction(thrustVectors)

//        let period = 0.01// Double.random(in: 0.25..<1.0)
        let md = SKAction.group([motionAction])
//        let md = SKAction.group([displayAction, motionAction])
//        let w = SKAction.wait(forDuration: period)

//        self.sprite.run(SKAction.sequence([md, w, r]))
        self.sprite.run(md, completion: { [unowned self] in self.tick() })
//        self.sprite.run(self.tickAction)
    }
}

// MARK: Initialization

extension Arkon {
    private static func setupSprite(_ fishNumber: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)
        sprite.size *= 0.3
        sprite.color = ArkonCentralLight.colors.randomElement()!
        sprite.colorBlendFactor = 0.5

        sprite.zPosition = ArkonCentralLight.vArkonZPosition

        sprite.name = "\(fishNumber)"

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        sprite.physicsBody!.affectedByGravity = true
        sprite.physicsBody!.isDynamic = true
        sprite.physicsBody!.categoryBitMask = 0x01
        sprite.physicsBody!.collisionBitMask = 0x01
        sprite.physicsBody!.fieldBitMask = 0x01
        sprite.physicsBody!.contactTestBitMask = 0x01

        return sprite
    }
}
