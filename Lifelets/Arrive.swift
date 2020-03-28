import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log(level: 156) { "Arrive \(six(st.name)) at \(six((st.gridCell)?.gridPosition)) manna \(st.gridCell.manna != nil)" }

        if shuttle.consumedStepper != nil { dp.parasitize(); return }
        if st.gridCell.manna != nil { graze(); return }

        dp.releaseShuttle()
    }

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let manna = st.gridCell.manna else { fatalError() }
        Debug.log(level: 156) { "graze \(st.name)" }

        manna.harvest { entropizedInJoules in
            Debug.log(level: 156) { "graze \(st.name) \(entropizedInJoules)" }

            // If we're just chewing on celery, we don't get a co2 reset
            if entropizedInJoules > 0 {
                st.metabolism.absorbEnergy(entropizedInJoules)
                ch.co2Counter = 0
            }

            dp.releaseShuttle()
        }
    }
}
