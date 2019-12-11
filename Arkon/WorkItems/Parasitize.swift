import Foundation

final class Parasitize: Dispatchable {
    internal override func launch_() {
        Log.L.write("Parasitize.launch_ \(six(scratch?.stepper?.name))", level: 22)
        let result = attack()
        parasitize(result.0, result.1)
    }
}

extension Parasitize {
    func attack() -> (Stepper, Stepper) {
        guard let (myScratch, _, myStepper) = scratch?.getKeypoints() else { fatalError() }

        guard let hisSprite = myScratch.cellTaxi?.consumedSprite else { fatalError() }
        guard let hisStepper = hisSprite.getStepper() else { fatalError() }

        let myMass = myStepper.metabolism.mass
        let hisMass = hisStepper.metabolism.mass

        Log.L.write("Parasitize: \(six(myStepper.name)) attacks \(six(hisStepper.name))", level: 28)

        if myMass > (hisMass * 1.25) {
            Log.L.write("Parasitize2: \(six(myStepper.name)) eats \(six(hisStepper.name))", level: 28)
            myStepper.isTurnabouted = false
            hisStepper.isTurnabouted = false
            return (myStepper, hisStepper)
        } else {
            myStepper.isTurnabouted = true
            hisStepper.isTurnabouted = true
            Log.L.write("Parasitize3: \(six(myStepper.name)) eats \(six(hisStepper.name))", level: 28)

            let hisScratch = hisStepper.dispatch.scratch
            let myTaxi = myScratch.cellTaxi

            precondition(hisScratch.engagerKey != nil)
            precondition(myTaxi != nil)

            hisScratch.cellTaxi = myTaxi
            myScratch.cellTaxi = nil

            return (hisStepper, myStepper)
        }
    }

    func parasitize(_ victor: Stepper, _ victim: Stepper) {
        victor.metabolism.parasitizeProper(victim)
        victor.dispatch.releaseStage()

        if victor.isTurnabouted {
            victim.dispatch.apoptosize()
        }
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
