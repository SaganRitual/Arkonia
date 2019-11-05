import Foundation

final class Parasitize: Dispatchable {

    weak var dispatch: Dispatch!
    var runningAsBarrier: Bool { return dispatch.runningAsBarrier }
    var stepper: Stepper { return dispatch.stepper }
    var victim: Stepper!

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() { aParasitize() }

    func inject(_ victim: Stepper?) { self.victim = victim }

}

extension Parasitize {
    func aParasitize() {
        assert(runningAsBarrier == true)
        stepper.metabolism.parasitize(victim)
        dispatch.funge()
    }
}

extension Metabolism {
    func parasitize(_ victim: Stepper) {
        let spareCapacity = stomach.capacity - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.metabolism.withdrawFromReady(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
