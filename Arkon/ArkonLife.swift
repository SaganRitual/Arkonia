import Foundation
import SpriteKit

extension Karamba {

    func eatArkon(_ victim: Karamba) {
        print("\(scab.fishNumber) eats \(victim.scab.fishNumber)")
        hunger -= victim.pBody.mass * 5.0
        pBody.mass += victim.pBody.mass * 0.5
    }

    func eatManna(_ bodies: [SKPhysicsBody]) {
        let touchedManna = bodies.filter { hardBind($0.node?.name).starts(with: "manna") }
        print("\(scab.fishNumber) touches \(touchedManna.count)")
        hunger -= CGFloat(touchedManna.count) * 1.0
        pBody.mass += CGFloat(touchedManna.count) * 0.1
    }

    private func getCSensedArkons(_ bodies: [SKPhysicsBody]) -> Int {
        let sensedArkons = bodies.filter { ($0.node?.name)?.starts(with: "arkon") ?? false }
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
        return position.makeVector(to: closestArkon!.node!.position)
    }

    private func getVectorToClosestManna(_ bodies: [SKPhysicsBody]) -> CGVector {
        let sensedManna = bodies.filter { $0.node?.name?.starts(with: "manna") ?? false }
        if sensedManna.isEmpty { return CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity) }
        let closestManna = sensedManna.min { $0.node!.position.radius < $1.node!.position.radius }
        return position.makeVector(to: closestManna!.node!.position)
    }

    func response() {
        let motorNeuronOutputs = scab.signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        response(motorNeuronOutputs: motorNeuronOutputs)
    }

    func stimulus() {
        let velocity = pBody.velocity
        let aVelocity = pBody.angularVelocity
        let vectorToOrigin = position.asVector()

        let vectorToClosestArkon: CGVector!
        let vectorToClosestManna: CGVector!

        let sb = sensedBodies ?? []
        if sb.isEmpty {
            vectorToClosestManna = CGVector.zero
            vectorToClosestArkon = CGVector.zero
        } else {
            vectorToClosestManna = getVectorToClosestManna(sb)
            vectorToClosestArkon = getVectorToClosestArkon(sb)
        }

        let sensoryInputs = [
            Double(aVelocity),
            Double(hunger),

            Double(velocity.radius), Double(velocity.theta),

            Double(vectorToOrigin.radius), Double(vectorToOrigin.theta),

            Double(getCSensedManna(sb)),
            Double(vectorToClosestManna.radius), Double(vectorToClosestManna.theta),

            Double(getCSensedArkons(sb)),
            Double(vectorToClosestArkon.radius), Double(vectorToClosestArkon.theta)
        ]

//        let truncked = sensoryInputs.map { String(format: "% -.5e", $0) }
//        print("inputs", pBody!.mass, truncked)

        let arkonSurvived = scab.signalDriver.drive(sensoryInputs: sensoryInputs)
        precondition(arkonSurvived, "\(scab.fishNumber) should have died from test signal in init")
    }

}
