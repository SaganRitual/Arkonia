import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        Debug.debugColor(stepper, .brown, .green)

        let ax = stepper.ingridCellAbsoluteIndex
        if let manna = Ingrid.shared!.manna.mannaAt(ax) { graze(manna); return }

        stepper.dispatch.disengageGrid()
    }

    func graze(_ manna: Manna) {
        stepper.cFoodHits += 1

        manna.harvest { _ in self.stepper.dispatch.disengageGrid() }
    }
}
