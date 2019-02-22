import Foundation
import SpriteKit

class Arkon {
    private let fishNumber: Int
    private let fNet: FNet
    private let genome: Genome
    private var kNet: KNet!
    private let motorOutputs: MotorOutputs
    private let portal: SKNode
    private let sprite: SKSpriteNode
    private var tickCount = 0

    var isAlive: Bool {
        get { return self.sprite.userData?["isAlive"] as? Bool ?? false }

        set {
            if self.sprite.userData == nil { return }
            self.sprite.userData!["isAlive"] = newValue
        }
    }

    init(fishNumber: Int, genome: Genome, fNet: FNet, portal: SKNode) {
        self.fishNumber = fishNumber
        self.genome = genome
        self.fNet = fNet

        let sprite = Arkon.setupSprite(fishNumber)
        self.motorOutputs = MotorOutputs(sprite)

        self.portal = portal
        self.sprite = sprite
        portal.addChild(sprite)

        self.isAlive = true
    }

    deinit {
        self.sprite.removeAllActions()
        self.sprite.removeFromParent()
    }

    func comeToLife() {
        let r = Double.random(in: 0.25..<1.0)
        let a = SKAction.wait(forDuration: r)
        let b = SKAction.run(tick)
        self.sprite.run(SKAction.sequence([a, b]))
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
        guard self.isAlive else { return }
        guard let portal = self.portal as? SKSpriteNode else { preconditionFailure() }

        guard portal.frame.contains(self.sprite.position) else {
            self.isAlive = false; return
        }

        let signalDriver = KSignalDriver(idNumber: self.fishNumber, fNet: self.fNet)
        self.kNet = signalDriver.kNet

        let arkonSurvived = signalDriver.drive(sensoryInputs: [1])
        if !arkonSurvived { return }

        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        let thrustVectors = getThrustVectors(motorNeuronOutputs)

        let motionAction = motorOutputs.getAction(thrustVectors)
//        let displayAction = getDisplayAction(thrustVectors)

        let period = Double.random(in: 0.25..<1.0)
        let md = SKAction.group([motionAction])
//        let md = SKAction.group([displayAction, motionAction])
        let w = SKAction.wait(forDuration: period)
        let r = SKAction.run(tick)

        self.sprite.run(SKAction.sequence([md, w, r]))
    }
}

// MARK: Initialization

extension Arkon {
    private static func setupSprite(_ fishNumber: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)
        sprite.size *= 0.3
        sprite.color = ArkonCentralLight.colors.randomElement()!
        sprite.colorBlendFactor = 0.25

        sprite.zPosition = ArkonCentralLight.vArkonZPosition

        sprite.name = "\(fishNumber)"

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)
        sprite.physicsBody!.affectedByGravity = true
        sprite.physicsBody!.isDynamic = true

        sprite.userData = [:]

        return sprite
    }
}
