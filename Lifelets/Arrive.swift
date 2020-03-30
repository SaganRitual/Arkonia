import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
//        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log(level: 156) { "Arrive \(six(st.name)) at \(six((st.gridCell)?.gridPosition)) manna \(st.gridCell.manna != nil)" }

//        if shuttle.consumedStepper != nil { dp.parasitize(); return }
        if st.gridCell.manna != nil { graze(); return }

        dp.releaseShuttle()
    }

    func graze() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let manna = st.gridCell.manna else { fatalError() }
        Debug.log(level: 156) { "graze \(st.name)" }

        manna.harvest { entropizedInJoules in
            Debug.log(level: 156) { "graze \(st.name) \(entropizedInJoules)" }

            if entropizedInJoules > 0 { self.postHarvest(entropizedInJoules) }

            dp.releaseShuttle()
        }
    }

    func postHarvest(_ entropizedInJoules: CGFloat) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }

        st.metabolism.absorbEnergy(entropizedInJoules)

        // If the manna isn't bloomed enough to be at full capacity
        // for mannaCo2AbsorberLevelOrSomething, then our co2 isn't
        // reset fully
        let co2AbsorberOrSomethingAvailable =
            entropizedInJoules / Arkonia.maxMannaEnergyContentInJoules

        let discount = (co2AbsorberOrSomethingAvailable > 0.25) ? 1 : co2AbsorberOrSomethingAvailable

        ch.co2Counter *= (1 - discount)
    }
}
