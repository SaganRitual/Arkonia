import Foundation

final class Parasitize: Dispatchable {
    weak var scratch: Scratchpad?

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    func launch() { aParasitize() }
}

extension Parasitize {
    func aParasitize() {
        guard let scr = scratch else { fatalError() }
        guard let victor = scr.battle?.0 else { fatalError() }
        guard let victim = scr.battle?.1 else { fatalError() }

        victor.metabolism.parasitize(victim)
    }
}

extension Metabolism {
    func parasitize(_ victim: Stepper) {
        let spareCapacity = stomach.capacity - stomach.level
        let victimEnergy = victim.metabolism.withdrawFromReady(spareCapacity)
        let netEnergy = victimEnergy * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
