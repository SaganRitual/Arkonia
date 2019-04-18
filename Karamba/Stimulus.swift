import Foundation
import SpriteKit

extension Karamba {

    func combat() -> CombatStatus {
        let contactedArkons = senseLoader.getContactedArkons()

        guard let ca = contactedArkons, ca.count == 1,
            let opponent = ca.first?.node as? Karamba,
            let oca = opponent.senseLoader.getContactedArkons(), oca.count <= 1
            else { return .surviving }

        return opponent.pBody.mass * opponent.pBody.velocity.magnitude >
            self.pBody.mass * self.pBody.velocity.magnitude ?
                .losing(opponent) : .winning(opponent)
    }

    func driveNetSignal() {
        if isAlive == false { return }
        let arkonSurvived = scab.signalDriver.drive(sensoryInputs: sensoryInputs)
        precondition(arkonSurvived, "\(scab.fishNumber) should have died from test signal in init")
    }

    func graze() -> HerbivoreStatus {
        let contactedManna = senseLoader.getContactedManna()

        guard let cm = contactedManna, cm.isEmpty == false else { return .goingHungry }
        return .grazing
    }

    func response() {
        assert(Display.displayCycle == .actions)
        guard isAlive else { return }
        let motorNeuronOutputs = scab.signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
        response(motorNeuronOutputs: motorNeuronOutputs)
    }

    func stimulus() { senseLoader.loadSenseData() }
}

extension Karamba {

    func eatArkon(_ victim: Karamba) {
        assert(Display.displayCycle != .physics)
        metabolism.absorbMeat(victim.pBody.mass)

        contactedBodies = contactedBodies?.filter { $0.node is Karamba }
        sensedBodies = sensedBodies?.filter { $0.node is Karamba }

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

        metabolism.absorbGreens(CGFloat(manna.mass))

        MannaFactory.shared.compost(manna)
        //        print("arkon \(scab.fishNumber) hunger = \(hunger), mass = \(pBody.mass), health = \(health)")
    }
}
