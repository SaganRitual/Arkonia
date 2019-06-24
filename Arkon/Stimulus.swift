import Foundation
import SpriteKit

extension Arkon {
    enum CombatStatus { case losing(Arkon), surviving, winning(Arkon)  }
    enum HerbivoreStatus { case goingHungry, grazing }

    func combat() -> CombatStatus {
        let contactedArkons = senseLoader.getContactedArkons()

        guard let ca = contactedArkons, ca.count == 1,
            let opponent = (ca.first?.node as? SKSpriteNode)?.arkon,
            let oca = opponent.senseLoader.getContactedArkons(), oca.count <= 1
            else { return .surviving }

        return opponent.pBody.mass * opponent.pBody.velocity.magnitude >
            self.pBody.mass * self.pBody.velocity.magnitude ?
                .losing(opponent) : .winning(opponent)
    }

    func graze() -> HerbivoreStatus {
        let contactedManna = senseLoader.getContactedManna()

        guard let cm = contactedManna, cm.isEmpty == false else { return .goingHungry }
        return .grazing
    }

    func response() -> [Double] {
        assert(Display.displayCycle == .actions)
        guard isAlive else { return [] }
        return net.getMotorOutputs(sensoryInputs)
    }

    func stimulus() -> [Double] {
        let senseLoader = SenseLoader(self)
        return senseLoader.loadSenseData()
    }
}