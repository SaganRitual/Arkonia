import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        Debug.debugColor(stepper, .brown, .green)

        let ax = stepper.gridCellAbsoluteIndex
        if let manna = Grid.shared.mannaAt(ax) { graze(manna); return }

        stepper.dispatch.disengageGrid()
    }

    func graze(_ manna: Manna) {
        stepper.cFoodHits += 1
        manna.harvest {
            if let mannaContent = $0 { self.stepper.metabolism.eat(mannaContent) }
            self.stepper.dispatch.disengageGrid()
        }
    }
}
