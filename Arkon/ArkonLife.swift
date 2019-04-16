import Foundation
import SpriteKit

extension Karamba {

    func eatArkon(_ victim: Karamba) {
        metabolism.absorbMeat(victim.pBody.mass)

        victim.apoptosize()
//        print("arkon \(scab.fishNumber) eats arkon \(victim.scab.fishNumber)")
    }

    func eatManna() {
        let contactedManna = contactedBodies?.filter {
            guard let manna = $0.node as? Manna else { return false }
            guard let name = manna.name else { return false }
            return name.starts(with: "manna") && !manna.isComposting
        }

        guard let cm = contactedManna, !cm.isEmpty else { return }
//        print("\(scab.fishNumber) eats \(cm.count) morsels of manna")
        cm.forEach { eatManna($0) }
    }

    func eatManna(_ mannaBody: SKPhysicsBody) {
        let manna = hardBind(mannaBody.node as? Manna)

        let startupMultiplier: CGFloat = (geneticParentFishNumber == nil) ? 3 : 3
        metabolism.absorbGreens(startupMultiplier * CGFloat(manna.calories))

        MannaFactory.shared.compost(manna)
//        print("arkon \(scab.fishNumber) hunger = \(hunger), mass = \(pBody.mass), health = \(health)")
    }

    func getContactedArkons() -> [SKPhysicsBody]? {
        let contactedArkons = contactedBodies?.filter { ($0.node?.name)?.starts(with: "arkon") ?? false }
//        if !(contactedArkons?.isEmpty ?? true) { print("arkon \(scab.fishNumber) contacts \(contactedArkons?.count ?? 0) arkons") }
        return contactedArkons
    }

    func getContactedManna() -> [SKPhysicsBody]? {
        let contactedManna = contactedBodies?.filter { ($0.node?.name)?.starts(with: "manna") ?? false }
//        print("arkon \(scab.fishNumber) contacts \(contactedManna?.count ?? 0) manna morsels")
        return contactedManna
    }

    private func getCSensedArkons() -> Int {
        let sensedArkons = sensedBodies?.filter { ($0.node?.name)?.starts(with: "arkon") ?? false }
        return sensedArkons?.count ?? 0
    }

    private func getCSensedManna() -> Int {
        let sensedManna = sensedBodies?.filter { ($0.node?.name)?.starts(with: "manna") ?? false }
        return sensedManna?.count ?? 0
    }

    private func getVectorToClosestArkon() -> CGVector {
        let sensedArkons = sensedBodies?.filter { $0.node?.name?.starts(with: "arkon") ?? false }
        if sensedArkons?.isEmpty ?? true { return CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity) }
        let closestArkon = sensedArkons?.min { $0.node!.position.radius < $1.node!.position.radius }

        guard let ca = closestArkon else { return CGVector.zero }
        let p = hardBind(ca.node?.position)
        return position.makeVector(to: p)
    }

    private func getVectorToClosestManna() -> CGVector {
        let sensedManna = sensedBodies?.filter { $0.node?.name?.starts(with: "manna") ?? false }
        if sensedManna?.isEmpty ?? true { return CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity) }
        let closestManna = sensedManna?.min { $0.node!.position.radius < $1.node!.position.radius }

        guard let cm = closestManna else { return CGVector.zero }
        let p = hardBind(cm.node?.position)
        return position.makeVector(to: p)
    }

    func netSignal() {
        let arkonSurvived = scab.signalDriver.drive(sensoryInputs: sensoryInputs)
        precondition(arkonSurvived, "\(scab.fishNumber) should have died from test signal in init")
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
            vectorToClosestManna = getVectorToClosestManna()
            vectorToClosestArkon = getVectorToClosestArkon()
        }

        sensoryInputs.removeAll(keepingCapacity: true)
        sensoryInputs.append(contentsOf: [Double](arrayLiteral:

            Double(aVelocity),
            Double(metabolism.hunger),
            Double(metabolism.oxygenLevel),

            Double(velocity.radius), Double(velocity.theta),

            Double(vectorToOrigin.radius), Double(vectorToOrigin.theta),

            Double(getCSensedManna()),
            Double(vectorToClosestManna?.radius ?? 0), Double(vectorToClosestManna?.theta ?? 0),

            Double(getCSensedArkons()),
            Double(vectorToClosestArkon?.radius ?? 0), Double(vectorToClosestArkon?.theta ?? 0)

        ))
    }

}
