import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log(level: 154) { "Arrive \(six(st.name))" }

        switch shuttle.consumedContents {
        case .arkon: dp.parasitize(); return
        case .nothing: break
        default: fatalError()
        }

        if st.gridCell.mannaSprite != nil { graze() }
    }

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let manna = st.gridCell.mannaSprite?.getManna(require: false) else { fatalError() }

        manna.harvest { entropizedInJoules in
            Debug.log(level: 154) { "graze \(entropizedInJoules)" }
            st.metabolism.absorbEnergy(entropizedInJoules)
            ch.co2Counter = 0
            dp.releaseShuttle()
        }
    }
}
