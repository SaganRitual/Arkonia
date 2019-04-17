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
        assert(Display.displayCycle == .actions)
        let motorNeuronOutputs = scab.signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        response(motorNeuronOutputs: motorNeuronOutputs)
    }

    func stimulus() {
        assert(Display.displayCycle == .actions)
        let velocity = pBody.velocity
        let aVelocity = pBody.angularVelocity
        let vectorToOrigin = position.asVector()

        let vectorToClosestArkon: CGVector!
        let vectorToClosestManna: CGVector!

        if sensedBodies?.isEmpty ?? true {
            vectorToClosestManna = CGVector.zero
            vectorToClosestArkon = CGVector.zero
        } else {
            vectorToClosestManna = getVectorToClosestManna()
            vectorToClosestArkon = getVectorToClosestArkon()
        }

        func portalScaleX(_ value: CGFloat) -> CGFloat {
            return 2 * value / PortalServer.shared.arkonsPortal.size.width
        }

        func portalScaleY(_ value: CGFloat) -> CGFloat {
            return 2 * value / PortalServer.shared.arkonsPortal.size.height
        }

        func pCircle(angle theta: CGFloat) -> CGFloat {
            return theta.truncatingRemainder(dividingBy: CGFloat.tau) / CGFloat.tau
        }

        func capCheck(_ value: CGFloat) -> CGFloat {
            assert(value >= 0 && value <= 1)
            return value
        }

        sensoryInputs.removeAll(keepingCapacity: true)

        sensoryInputs.append(contentsOf: [Double](arrayLiteral:

            Double(pCircle(angle: aVelocity)),
//            Double(capCheck(metabolism.hunger)),
            Double(capCheck(metabolism.oxygenLevel)),

            Double(portalScaleX(velocity.dx)),
            Double(portalScaleY(velocity.dy)),

            Double(portalScaleX(vectorToOrigin.dx)),
            Double(portalScaleY(vectorToOrigin.dy)),

            Double(getCSensedManna()),
            Double(portalScaleX(vectorToClosestManna?.dx ?? 0)),
            Double(portalScaleY(vectorToClosestManna?.dy ?? 0)),

            Double(getCSensedArkons()),
            Double(portalScaleX(vectorToClosestArkon?.dx ?? 0)),
            Double(portalScaleY(vectorToClosestArkon?.dy ?? 0))

        ))
    }

}
