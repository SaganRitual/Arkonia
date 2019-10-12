import Foundation

extension Metabolism {
    func parasitize(_ victim: Metabolism, completion: @escaping CoordinatorCallback) {
        let workItem = { [unowned self] in
            self.parasitize_(victim)
            completion()
        }

        workItem()
//        syncQueue.async(flags: .barrier, execute: workItem)
    }

    func parasitize_(_ victim: Metabolism) {
        let spareCapacity = stomach.capacity - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.withdrawFromReady(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch * 0.75

        absorbEnergy(netEnergy)
        inhale()
    }
}
