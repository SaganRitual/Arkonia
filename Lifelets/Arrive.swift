import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Debug.log(level: 85) { "Arrive \(six(st.name))" }

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
            Debug.log(level: 97) { "graze \(entropizedInJoules)" }
            st.metabolism.absorbEnergy(entropizedInJoules)
            ch.co2Counter = 0
            dp.releaseShuttle()
        }
    }
}
