import Dispatch

final class Arrive: Dispatchable {
    internal override func launch_() { arrive() }

    func arrive() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        switch taxi.consumedContents {
        case .arkon: dp.parasitize()
        case .manna: graze()
        default: fatalError()
        }
    }
}

extension Arrive {

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        guard let sprite = taxi.consumedSprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        let harvested = manna.harvest()

        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale(manna.energyFullness)

        MannaCoordinator.shared.beEaten(sprite)

        dp.releaseStage()
    }

}
