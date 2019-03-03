import Foundation
import SpriteKit

extension Arkon {

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

    private func spawn() {
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
    }

    private func stimulus(dToOrigin: Double) {
        let θToOrigin = Double(atan2(self.sprite.position.y, self.sprite.position.x))

        let velocity = self.sprite.physicsBody?.velocity ?? CGVector.zero

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: [dToOrigin, θToOrigin, Double(velocity.dx), Double(velocity.dy)]
        )

        precondition(arkonSurvived, "Should have died from test signal in init")
    }

    func tick() {
        self.isAlive = true

        if self.sprite.userData == nil { preconditionFailure("Shouldn't happen; I'm desperate") }
        if !self.isInBounds || !self.isHealthy { apoptosize(); return }

        let dToOrigin = Double(hypotf(Float(-self.sprite.position.x), Float(-self.sprite.position.y)))
        precondition(dToOrigin >= 0)

        // If I spawn, I'm idle and vulnerable until I'm finished
        if health > 20 { spawn(); return }

        health -= 1.0       // Time and tick wait for no arkon
        health += 1000.0 / ((dToOrigin < 1) ? 1 : pow(dToOrigin, 1.2))

        stimulus(dToOrigin: dToOrigin)
        response()
    }

}
