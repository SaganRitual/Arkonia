import Foundation
import SpriteKit

extension SKSpriteNode {

    func normalizeAngleToTau(_ angle: CGFloat) -> CGFloat {
        if angle == 0 || angle.isInfinite { return 0 }
        let sign = abs(angle) / angle

        let scaled = abs(angle).truncatingRemainder(dividingBy: CGFloat.tau) / CGFloat.tau
        return scaled * sign
    }

    func normalizeVectorToEnvironment(_ vector: CGVector, portal: SKSpriteNode) -> CGVector {
        if vector == CGVector.zero { return CGVector.zero }
        let hypotenuse = vector.asSize().hypotenuse
        let normalizedR = (2 * vector.magnitude / hypotenuse) * ArkonFactory.scale
        let normalizedΘ = normalizeAngleToTau(vector.theta)
        return CGVector(radius: normalizedR, theta: normalizedΘ)
    }
}

extension Karamba {

    private enum Subset: String { case arkon, manna }

    func combat() -> CombatStatus {
        let contactedArkons = getContactedArkons()

        guard let ca = contactedArkons, ca.count == 1,
            let opponent = ca.first?.node as? Karamba,
            let oca = opponent.getContactedArkons(), oca.count <= 1
            else { return .surviving }

        return opponent.pBody.mass * opponent.pBody.velocity.magnitude >
            self.pBody.mass * self.pBody.velocity.magnitude ?
                .losing(opponent) : .winning(opponent)
    }

    private func countSensedArkons() -> CGFloat? { return countSensedBodies(.arkon) }

    private func countSensedBodies(_ subset: Subset) -> CGFloat? {
        guard let bodies = getBodies(subset, from: sensedBodies) else { return nil }
        if bodies.isEmpty { return nil }
        return 1.0 / CGFloat(bodies.count)
    }

    private func countSensedManna() -> CGFloat? { return countSensedBodies(.manna) }

    func driveNetSignal() {
        let arkonSurvived = scab.signalDriver.drive(sensoryInputs: sensoryInputs)
        precondition(arkonSurvived, "\(scab.fishNumber) should have died from test signal in init")
    }

    private func getBodies(_ subset: Subset, from fullSet: [SKPhysicsBody]?)
        -> [SKPhysicsBody]? {

        guard let fs = fullSet else { return nil }

        let result = fs.filter {
            guard let node = $0.node else { return false }
            guard let name = node.name else { return false }
            return name.starts(with: subset.rawValue)
        }

        return result.isEmpty ? nil : result
    }

    private func getContactedArkons() -> [SKPhysicsBody]? {
        return getBodies(.arkon, from: contactedBodies)
    }

    private func getContactedManna() -> [SKPhysicsBody]? {
        return getBodies(.manna, from: contactedBodies)
    }

    private func getSensedArkons() -> [SKPhysicsBody]? {
        return getBodies(.arkon, from: sensedBodies)
    }

    private func getSensedManna() -> [SKPhysicsBody]? {
        return getBodies(.manna, from: sensedBodies)
    }

    private func getVectorToClosestSensedArkon() -> CGVector? {
        return getVectorToClosestSensedBody(.arkon)
    }

    private func getVectorToClosestSensedBody(_ subset: Subset) -> CGVector? {
        guard var sensed = (subset == .arkon) ?
            getSensedArkons() : getSensedManna() else { return nil }

        let contacted = (subset == .arkon) ? getContactedArkons() : getContactedManna()

        if sensed.isEmpty {
            sensed = sensed.compactMap {
                guard let touched = contacted else { return nil }
                return touched.contains($0) ? nil : $0
            }
        }

        if sensed.isEmpty { return nil }
        let closest = sensed.min {
            guard let lhsNode = $0.node, let rhsNode = $1.node else { assert(false) }
            if lhsNode.position == rhsNode.position { return Bool.random() }
            return position.distance(to: lhsNode.position) < position.distance(to: rhsNode.position)
        }

        guard let closestNode = closest?.node else { assert(false) }
        let fromMeToHim = position.makeVector(to: closestNode.position)
        let raw = CGVector(radius: fromMeToHim.radius, theta: fromMeToHim.theta)
        return normalizeVectorToEnvironment(raw, portal: portal)
    }

    private func getVectorToClosestSensedManna() -> CGVector? {
        return getVectorToClosestSensedBody(.manna)
    }

    func graze() -> HerbivoreStatus {
        let contactedManna = getContactedManna()

        guard let cm = contactedManna, cm.isEmpty == false else { return .goingHungry }
        return .grazing
    }

    func response() {
        assert(Display.displayCycle == .actions)
        let motorNeuronOutputs = scab.signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        response(motorNeuronOutputs: motorNeuronOutputs)
    }

    // swiftmint:disable function_body_length
    func stimulus() {
        assert(Display.displayCycle == .actions)
        let aVelocity = normalizeAngleToTau(pBody.angularVelocity)
        let portal = PortalServer.shared.arkonsPortal
        let vectorToOrigin = normalizeVectorToEnvironment(position.asVector(), portal: portal)
        let velocity = normalizeVectorToEnvironment(pBody.velocity, portal: portal)

        let vectorToClosestArkon = getVectorToClosestSensedArkon()
        let vectorToClosestManna = getVectorToClosestSensedManna()

        func fullCapCheck(_ value: CGFloat) -> CGFloat {
            guard (value >= -1 && value <= 1) || value.isInfinite else {
                print("died?", scab.fishNumber, value)
                assert(false)
                return 0.0
            }

            return value
        }

        func halfCapCheck(_ value: CGFloat) -> CGFloat {
            assert(value >= 0 && value <= 1)
            return value
        }

        sensoryInputs.removeAll(keepingCapacity: true)

        let inputs = [Double](arrayLiteral:

            Double(fullCapCheck(aVelocity)),
            Double(halfCapCheck(metabolism.oxygenLevel)),

            Double(fullCapCheck(velocity.magnitude)),
            Double(fullCapCheck(velocity.theta)),

            Double(fullCapCheck(vectorToOrigin.magnitude)),
            Double(fullCapCheck(vectorToOrigin.theta)),

            Double(halfCapCheck(countSensedManna() ?? 0)),
            Double(fullCapCheck(vectorToClosestManna?.magnitude ?? CGFloat.infinity)),
            Double(fullCapCheck(vectorToClosestManna?.theta ?? 0)),

            Double(halfCapCheck(countSensedArkons() ?? 0)),
            Double(fullCapCheck(vectorToClosestArkon?.magnitude ?? CGFloat.infinity)),
            Double(fullCapCheck(vectorToClosestArkon?.theta ?? 0))

        )

       print("i", terminator: "")
        inputs.forEach {
            let t = String(format: "%-.3f", $0)
            print(", \(t)", terminator: "")
        }
        print(" arkon ", scab.fishNumber)
        sensoryInputs.append(contentsOf: inputs)
    }
    // swiftmint:enable function_body_length

}

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

        let startupMultiplier: CGFloat = (geneticParentFishNumber == nil) ? 5 : 5
        metabolism.absorbGreens(startupMultiplier * CGFloat(manna.calories))

        MannaFactory.shared.compost(manna)
        //        print("arkon \(scab.fishNumber) hunger = \(hunger), mass = \(pBody.mass), health = \(health)")
    }
}
