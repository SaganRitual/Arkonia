import Foundation
import SpriteKit

extension Arkon {

    static func absorbFood(_ sprite: SKSpriteNode) {
        guard let arkon = sprite.userData?["Arkon"] as? Arkon else { preconditionFailure() }

        arkon.health += 10.0
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

    private func response() {
        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        let thrustVectors = getThrustVectors(motorNeuronOutputs)
        let motionAction = motorOutputs.getAction(thrustVectors)
        let md = SKAction.group([motionAction])
        self.sprite.run(md, completion: { [unowned self] in self.tick() })
    }

    static func senseFood(_ arkonSprite: SKSpriteNode, _ mannaSprite: SKSpriteNode) {
        guard let arkon = arkonSprite.userData?["Arkon"] as? Arkon else { preconditionFailure() }
        arkon.foodPosition = mannaSprite.position
    }

    private func spawn() {
        precondition(self.observer == nil)

        let nName = Foundation.Notification.Name.arkonIsBorn
        let nCenter = NotificationCenter.default

        self.observer = nCenter.addObserver(forName: nName, object: nil, queue: nil) {
            [weak self] (notification: Notification) in

            guard let myself = self else { return }
            guard let u = notification.userInfo as? [String: Int] else { return }
            guard let f = u["parentFishNumber"] else { return }

            if f == myself.fishNumber {
                myself.health -= 10.0
                myself.sprite.run(myself.tickAction)
                nCenter.removeObserver(myself.observer!)
                myself.observer = nil
            }
        }

        World.shared.arkonery.spawn(parentID: self.fishNumber, parentGenome: self.genome)
    }

    private func stimulus() {
        let velocity = self.sprite.physicsBody?.velocity ?? CGVector.zero

        var θToFood = CGFloat(0)
        var dToFood = CGFloat(0)
        if foodPosition != CGPoint.zero {
            θToFood = CGFloat(atan2(foodPosition.y, foodPosition.x))
            dToFood = foodPosition.distance(to: sprite.position)
        }

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: [
                Double(velocity.dx), Double(velocity.dy),
                Double(dToFood), Double(θToFood)
            ]
        )

        precondition(arkonSurvived, "Should have died from test signal in init")
    }

    func tick() {
        self.isAlive = true

        if !self.isInBounds || !self.isHealthy { apoptosize(); return }

        // If I spawn, I'm idle and vulnerable until I'm finished
        if health > 30 { spawn(); return }

        health -= 1.0       // Time and tick wait for no arkon

        stimulus()
        response()
    }

}
