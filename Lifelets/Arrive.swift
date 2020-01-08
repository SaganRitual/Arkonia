import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log("Arrive \(six(st.name))", level: 71)

        switch shuttle.consumedContents {
        case .arkon: dp.parasitize()
        case .manna: graze()
        default: fatalError()
        }
    }

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        guard let mannaSprite = shuttle.consumedSprite else { fatalError() }

        ch.stillCounter /= 2

        mannaSprite.getManna()!.harvest { entropizedInJoules in
            st.metabolism.absorbEnergy(entropizedInJoules)
            dp.releaseStage()
        }
    }
}
