import Foundation

final class Parasitize: Dispatchable {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        if !scratch.isApoptosizing { self.scratch = scratch }
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
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

<<<<<<< HEAD
    func aParasitize(_ victor: Stepper, _ victim: Stepper) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }

        victor.metabolism.parasitize(victim)

<<<<<<< HEAD
        Grid.shared.concurrentQueue.sync(flags: .barrier) {
            Log.L.write("stepper \(six(victor.name)) clears gridconnector; parasitizes \(six(victim.name))")
            scr.gridCellConnector = nil
||||||| parent of 3df1d3e... Defensive
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            Log.L.write("stepper \(six(victor.name)) clears gridconnector; parasitizes \(six(victim.name))")
            scr.gridCellConnector = nil
=======
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            ch.gridCellConnector = nil
>>>>>>> 3df1d3e... Defensive

            victim.dispatch.apoptosize()
            victor.dispatch.funge()
        }
||||||| parent of fe41e59... Defensive
    func aParasitize(_ victor: Stepper, _ victim: Stepper) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }

        victor.metabolism.parasitize(victim)

        Grid.shared.concurrentQueue.async(flags: .barrier) {
            ch.gridCellConnector = nil

            victim.dispatch.apoptosize()
            victor.dispatch.funge()
        }
=======
    func parasitize(_ victor: Stepper, _ victim: Stepper) {
        victor.metabolism.parasitizeProper(victim)
        victor.dispatch.disengage()
>>>>>>> fe41e59... Defensive
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
