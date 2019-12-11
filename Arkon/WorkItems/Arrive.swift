import CoreGraphics
import Dispatch

final class Arrive: Dispatchable {
    override func launch() {
        guard let w = wiLaunch else { fatalError() }
        World.shared.concurrentQueue.async(execute: w)
    }

    internal override func launch_() { arrive() }

    func arrive() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        // We don't reset this when they begin moving, but rather we wait
        // until here, so they don't live forever while flopping around in
        // the empty corners
        ch.stillCounter = 0

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
        let inhaleFudgeFactor: CGFloat = 2.0

        st.metabolism.absorbEnergy(harvested)

        let toInhale = inhaleFudgeFactor * harvested / Manna.maxEnergyContentInJoules
        st.metabolism.inhale(toInhale)
        Log.L.write("inhale(\(String(format:"%-2.6f", toInhale)))", level: 35)

        MannaCoordinator.shared.beEaten(sprite)

        dp.releaseStage()
    }

}
