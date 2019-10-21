import Foundation

extension Stepper {
    func parasitize(_ victim: Stepper) {
        metabolism.parasitize(victim)
    }
}

extension Metabolism {
    func parasitize(_ victim: Stepper) {
        func workItem() -> [Void]? { parasitize_(victim); return nil }
        func finalize(_ nothing: [Void]?) { victim.apoptosize() }

        World.lock(workItem, finalize)
    }

    func parasitize_(_ victim: Stepper) {
        assert(!victim.isApoptosizing)
        victim.isApoptosizing = true

        let spareCapacity = stomach.capacity - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.metabolism.withdrawFromReady(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
