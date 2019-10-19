import Foundation

extension Metabolism {
    func parasitize(_ victim: Metabolism, completion: @escaping CoordinatorCallback) {
        print("parasitize: \(self.core!.selectoid.fishNumber) eats \(victim.core!.selectoid.fishNumber)")
        let workItem = { [unowned self] in
            self.parasitize_(victim)
        }

        Lockable<Void>().lock(workItem, { _ in completion() })
    }

    func parasitize_(_ victim: Metabolism) {
        let spareCapacity = stomach.capacity - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.withdrawFromReady(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
