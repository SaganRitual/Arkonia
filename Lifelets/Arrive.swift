import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log("Arrive \(six(st.name))", level: 85)

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

        mannaSprite.getManna()!.harvest { entropizedInJoules in
            Debug.log("graze \(entropizedInJoules)", level: 97)
            st.metabolism.absorbEnergy(entropizedInJoules)
            ch.co2Counter = 0
            dp.releaseShuttle()
        }
    }
}
