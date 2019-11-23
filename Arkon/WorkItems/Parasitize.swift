import Foundation

final class Parasitize: Dispatchable {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Parasitize()", select: 3)
        if !scratch.isApoptosizing { self.scratch = scratch }
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        Log.L.write("Parasitize.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        Log.L.write("Parasitize.launch_", select: 3)
        let result = attack()
        parasitize(result.0, result.1)
    }
}

extension Parasitize {
    func attack() -> (Stepper, Stepper) {
        guard let (ch, _, myStepper) = scratch?.getKeypoints() else { fatalError() }

        guard let hisSprite = ch.stage.to.sprite else { fatalError() }
        guard let hisStepper = hisSprite.getStepper() else { fatalError() }

        let myMass = myStepper.metabolism.mass
        let hisMass = hisStepper.metabolism.mass

        return (myMass > (hisMass * 1.25)) ?
            (myStepper, hisStepper) : (hisStepper, myStepper)
    }

    func parasitize(_ victor: Stepper, _ victim: Stepper) {
        victor.metabolism.parasitizeProper(victim)
        victor.dispatch.disengage()
        victor.dispatch.releaseStage(wiLaunch!)
    }
}

extension Metabolism {
    func parasitizeProper(_ victim: Stepper) {
        let spareCapacity = stomach.capacity - stomach.level
        let victimEnergy = victim.metabolism.withdrawFromReady(spareCapacity)
        let netEnergy = victimEnergy * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
