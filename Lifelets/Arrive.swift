import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
//        if shuttle.consumedStepper != nil { dispatch.parasitize(); return }
        if scratch.stepper.gridCell.manna != nil { graze(); return }

        scratch.dispatch!.releaseShuttle()
    }

    func graze() {
        guard let manna = scratch.stepper.gridCell.manna else { fatalError() }
        Debug.log(level: 156) { "graze \(scratch.stepper.name)" }

        manna.harvest { entropizedInJoules in
            Debug.log(level: 156) { "graze \(self.scratch.stepper.name) \(entropizedInJoules)" }

            if entropizedInJoules > 0 { self.postHarvest(entropizedInJoules) }

            self.scratch.dispatch!.releaseShuttle()
        }
    }

    func postHarvest(_ entropizedInJoules: CGFloat) {
        scratch.stepper.metabolism.absorbEnergy(entropizedInJoules)

        // If the manna isn't bloomed enough to be at full capacity
        // for mannaCo2AbsorberLevelOrSomething, then our co2 isn't
        // reset fully
        let co2AbsorberOrSomethingAvailable =
            entropizedInJoules / Arkonia.maxMannaEnergyContentInJoules

        let discount = (co2AbsorberOrSomethingAvailable > 0.25) ? 1 : co2AbsorberOrSomethingAvailable

        scratch.co2Counter *= (1 - discount)
    }
}
