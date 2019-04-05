import Foundation
import SpriteKit

extension Arkon {
    private func eatManna(_ bodies: [SKPhysicsBody]) {
        let touchedManna = bodies.filter { hardBind($0.node?.name).starts(with: "manna") }
        print("\(fishNumber) touches \(touchedManna.count)")
        hunger -= CGFloat(touchedManna.count) * 50.0
        nok(sprite.physicsBody).mass += CGFloat(touchedManna.count) * 50.0
    }

    private func response() {
        let motorNeuronOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        sprite.response(motorNeuronOutputs: motorNeuronOutputs)
    }

    private func getCSensedArkons(_ bodies: [SKPhysicsBody]) -> Int {
        let sensedArkons = bodies.filter { $0.node!.name!.starts(with: "arkon") }
        return sensedArkons.count
    }

    private func getCSensedManna(_ bodies: [SKPhysicsBody]) -> Int {
        let sensedManna = bodies.filter { ($0.node?.name)?.starts(with: "manna") ?? false }
        return sensedManna.count
    }

    private func getVectorToClosestArkon(_ bodies: [SKPhysicsBody]) -> CGVector {
        let sensedArkons = bodies.filter { $0.node?.name?.starts(with: "arkon") ?? false }
        if sensedArkons.isEmpty { return CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity) }
        let closestArkon = sensedArkons.min { $0.node!.position.radius < $1.node!.position.radius }
        return sprite.position.makeVector(to: closestArkon!.node!.position)
    }

    private func getVectorToClosestManna(_ bodies: [SKPhysicsBody]) -> CGVector {
        let sensedManna = bodies.filter { $0.node?.name?.starts(with: "manna") ?? false }
        if sensedManna.isEmpty { return CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity) }
        let closestManna = sensedManna.min { $0.node!.position.radius < $1.node!.position.radius }
        return sprite.position.makeVector(to: closestManna!.node!.position)
    }

    private func stimulus() {
        let velocity = self.sprite.physicsBody?.velocity ?? CGVector.zero
        let aVelocity = self.sprite.physicsBody?.angularVelocity ?? 0
        let vectorToOrigin = sprite.position.asVector()

        let contactedBodies = ?!self.sprite.physicsBody?.allContactedBodies()

        let vectorToClosestArkon = getVectorToClosestArkon(contactedBodies)
        let vectorToClosestManna = getVectorToClosestManna(contactedBodies)

        let sensoryInputs = [
            Double(aVelocity),
            Double(hunger),

            Double(velocity.radius), Double(velocity.theta),

            Double(vectorToOrigin.radius), Double(vectorToOrigin.theta),

            Double(getCSensedManna(contactedBodies)),
            Double(vectorToClosestManna.radius), Double(vectorToClosestManna.theta),

            Double(getCSensedArkons(contactedBodies)),
            Double(vectorToClosestArkon.radius), Double(vectorToClosestArkon.theta)
        ]

//        let truncked = sensoryInputs.map { String(format: "% -.5e", $0) }
//        print("inputs", sprite.physicsBody!.mass, truncked)

        let arkonSurvived = signalDriver.drive(sensoryInputs: sensoryInputs)
        precondition(arkonSurvived, "\(fishNumber) should have died from test signal in init")
    }

    func tick() {
        // FIXME -- The explanation below is bullshit. Who wrote this crap?
        // If you don't want ticks, don't connect.
        //
        // Because the display will start ticking us as soon as we add
        // to the scene, but there's a lot more that needs to be done
        // before we're ready for ticks.
        if !status.isAlive { return }

        if !isInBounds || sprite.physicsBody!.mass <= 0 {
            print("dead", fishNumber, hunger, sprite.physicsBody!.mass)
            sprite.run(apoptosizeAction); return }

        if sprite.physicsBody!.velocity.radius > 7.0 {
            sprite.color = .purple
        } else {
            sprite.color = .green
        }

        stimulus()
        response()
    }

}
