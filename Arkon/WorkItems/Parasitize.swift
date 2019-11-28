import Foundation

final class Parasitize: Dispatchable {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Parasitize()", level: 3)
        if !scratch.isApoptosizing { self.scratch = scratch }
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        Log.L.write("Parasitize.launch_ \(six(scratch?.stepper?.name))", level: 15)
        let result = attack()
        parasitize(result.0, result.1)
    }
}

extension Parasitize {
    func attack() -> (Stepper, Stepper) {
        guard let (ch, _, myStepper) = scratch?.getKeypoints() else { fatalError() }

        guard let hisSprite = ch.getStageConnector(require: true)?.toCell.sprite else { fatalError() }
        guard let hisStepper = hisSprite.getStepper() else { fatalError() }

        let myMass = myStepper.metabolism.mass
        let hisMass = hisStepper.metabolism.mass

        return (myMass > (hisMass * 1.25)) ?
            (myStepper, hisStepper) : (hisStepper, myStepper)
    }

    func parasitize(_ victor: Stepper, _ victim: Stepper) {
        victor.metabolism.parasitizeProper(victim)
        victor.dispatch.releaseStage()
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
