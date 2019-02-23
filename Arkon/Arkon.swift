import Foundation
import SpriteKit

class Arkon {
    private var destructAction: SKAction!
    let fishNumber: Int
    private let fNet: FNet
    private let genome: Genome
    private var kNet: KNet!
    private let lifespanInTicks = 10
    private var motorOutputs: MotorOutputs!
    private var portal: SKSpriteNode!
    let signalDriver: KSignalDriver
    var sprite: SKSpriteNode!
    private var tickAction: SKAction!
    private var tickCount = 0

    var drawn = false
    var isInBounds: Bool {
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

    init(genome: Genome, fNet: FNet, portal: SKSpriteNode) {
        self.fishNumber = ArkonCentralDark.selectionControls.theFishNumber
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.portal = portal

        self.genome = genome
        self.fNet = fNet
        self.signalDriver = KSignalDriver(idNumber: self.fishNumber, fNet: fNet)

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle
    }

    func launch() {
        let sprite = Arkon.setupSprite(fishNumber)
        self.motorOutputs = MotorOutputs(sprite)

        self.sprite = sprite
        portal.addChild(sprite)

        self.sprite.userData = ["Arkon": self]  // Ref to self; we're on our own after birth

        self.destructAction = SKAction.sequence([
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in self?.sprite.userData?["Arkon"] = nil }
        ])

        self.tickAction = SKAction.run(
            { [weak self] in self?.tick() }, queue: World.shared.dispatchQueue
        )

        self.sprite.run(self.tickAction)
    }

    deinit { self.sprite?.removeFromParent() }
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
        if self.sprite.userData == nil { preconditionFailure("Shouldn't happen; I'm desperate") }
        if !self.isInBounds { apoptosize(); return }

        tickCount += 1
//        if tickCount >= lifespanInTicks { apoptosize(); return }
        if tickCount % 3 == 0 { World.shared.arkonery.launchArkon() }

        let rToOrigin = Double(hypotf(Float(-self.sprite.position.x), Float(-self.sprite.position.y)))
        let θToOrigin = Double(atan2(self.sprite.position.y, self.sprite.position.x))
        let arkonSurvived = signalDriver.drive(sensoryInputs: [rToOrigin, θToOrigin])

        if !arkonSurvived { apoptosize(); return }

        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        let thrustVectors = getThrustVectors(motorNeuronOutputs)
        let motionAction = motorOutputs.getAction(thrustVectors)
//        let displayAction = getDisplayAction(thrustVectors)

//        let period = 0.01// Double.random(in: 0.25..<1.0)
        let md = SKAction.group([motionAction])
//        let md = SKAction.group([displayAction, motionAction])
//        let w = SKAction.wait(forDuration: period)

//        self.sprite.run(SKAction.sequence([md, w, r]))
        self.sprite.run(SKAction.sequence([md, self.tickAction]))
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

        return sprite
    }
}
