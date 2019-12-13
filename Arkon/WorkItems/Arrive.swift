import CoreGraphics
import Dispatch

final class Arrive: Dispatchable {
    override func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.serialQueue.async(execute: w)
//        World.shared.concurrentQueue.async(execute: w)
    }

    internal override func launch_() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        precondition(shuttle.toCell != nil && shuttle.toCell?.sprite?.name == st.name)

        Log.L.write("Arrive: \(six(st.name))/\(six(shuttle.fromCell?.ownerName)) at \(st.gridCell.gridPosition)\(shuttle.fromCell?.gridPosition ?? AKPoint(x: -4242, y: -4242)) attacks \(six(shuttle.consumedSprite?.name))/\(six(shuttle.toCell?.ownerName)) at \(shuttle.toCell?.gridPosition ?? AKPoint(x: -4242, y: -4242))/\(shuttle.consumedSprite?.position ?? CGPoint(x: -4242, y: -4242))", level: 55)

        // We don't reset this when they begin moving, but rather we wait
        // until here, so they don't live forever while flopping around in
        // the empty corners
        ch.stillCounter = 0

        switch shuttle.consumedContents {
        case .arkon:
            dp.parasitize()

        case .manna:
            graze()

        default: fatalError()
        }
    }
}

extension Arrive {
    func graze() { Grid.shared.serialQueue.async { self.graze_() } }

    func graze_() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }

        guard let sprite = shuttle.consumedSprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        let inhaleFudgeFactor: CGFloat = 2.0
        var harvested: CGFloat = 0

        func partA() { manna.harvest { harvested = $0; partB() } }

        func partB() {
            st.metabolism.absorbEnergy(harvested)

            let toInhale = inhaleFudgeFactor * harvested / Manna.maxEnergyContentInJoules
            st.metabolism.inhale(toInhale)
            Log.L.write("inhale(\(String(format:"%-2.6f", toInhale)))", level: 35)

            MannaCoordinator.shared.beEaten(sprite)

            precondition(
                (ch.cellShuttle?.fromCell != nil) &&
                (ch.cellShuttle?.toCell?.sprite?.getStepper(require: false) != nil)
            )

            dp.releaseStage()
        }

        partA()
    }

}
