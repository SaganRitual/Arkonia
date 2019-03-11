import Foundation
import SpriteKit

extension Arkon {
    static func absorbFood(_ arkonSprite: SKSpriteNode, _ mannaSprite: SKSpriteNode) {
        arkonSprite.arkon?.health += mannaSprite.foodValue
        arkonSprite.arkon?.targetManna = nil

        MannaFactory.shared.compost(mannaSprite)
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

    static func loseTrackOfFood(_ arkonSprite: SKSpriteNode, _ mannaSprite: SKSpriteNode) {
        guard let (idOfMorselIThoughtISaw, _) = arkonSprite.arkon!.targetManna else { return }

        guard let idOfNearbyMorsel = mannaSprite.name else { preconditionFailure() }
        guard idOfMorselIThoughtISaw == idOfNearbyMorsel else { return }

        arkonSprite.arkon!.targetManna = nil
    }

    private func response() {
        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        let thrustVectors = getThrustVectors(motorNeuronOutputs)
        let motionAction = motorOutputs.getAction(thrustVectors)
        self.sprite.run(motionAction, completion: tick)
    }

    static func senseFood(_ arkonSprite: SKSpriteNode, _ mannaSprite: SKSpriteNode) {
        if arkonSprite.arkon!.targetManna == nil {
            arkonSprite.arkon!.targetManna = (mannaSprite.name!, mannaSprite.position)
        }
    }

    private func spawn() {
        health -= 8
        self.sprite.color = .red
        ArkonFactory.shared.spawn(parentFishNumber: fishNumber, parentGenome: genome)

        if self.isOldestArkon {
            Arkon.currentHealthOfOldestArkon = health
            Arkon.currentCOffspring = cOffspring
        }
    }

    private func stimulus() {
        let velocity = self.sprite.physicsBody?.velocity ?? CGVector.zero
        let aVelocity = self.sprite.physicsBody?.angularVelocity ?? 0
        let position = self.sprite.position

        // (r, θ) to origin so they can evolve to stay in bounds
        var rToOrigin = CGFloat(0)
        var θToOrigin = CGFloat(0)
        if position != CGPoint.zero {
            rToOrigin = position.distance(to: CGPoint.zero)
            θToOrigin = atan2(position.y, position.x)
        }

        var θToFood = CGFloat(0)
        var rToFood = CGFloat(0)
        if let (_, foodPosition) = self.targetManna {
            rToFood = foodPosition.distance(to: sprite.position)
            θToFood = atan2(foodPosition.y, foodPosition.x)
        }

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: [
                Double(aVelocity),
                Double(rToOrigin), Double(θToOrigin),
                Double(rToFood), Double(θToFood),
                Double(velocity.dx), Double(velocity.dy)
            ]
        )

        precondition(arkonSurvived, "Should have died from test signal in init")
    }

    func tick() {
        if !self.isInBounds || !self.isHealthy {
            self.sprite.run(apoptosizeAction)
            return
        }

        if health > 10 && (myAge - myAgeAtLastSpawn) > 1.0 {
            myAgeAtLastSpawn = myAge
            spawn()
            return
        }

        health -= 1.0       // Time and tick wait for no arkon

        if self.isOldestArkon { Arkon.currentHealthOfOldestArkon = health }

        stimulus()
        response()
    }

}
