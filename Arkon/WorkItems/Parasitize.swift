import Foundation

extension Metabolism {
    func parasitize(_ victim: Metabolism, completion: @escaping CoordinatorCallback) {
        print("parasitize: \(self.core!.selectoid.fishNumber) eats \(victim.core!.selectoid.fishNumber)")
        func workItem() -> [Void]? { parasitize_(victim); return nil }
        print("dl parasitize")
        Catchall.lock(workItem)
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
