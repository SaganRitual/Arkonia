import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        Debug.debugColor(stepper, .brown, .green)

        let ax = stepper.ingridCellAbsoluteIndex
        if let manna = Ingrid.shared!.manna.mannaAt(ax) { graze(manna); return }

        Debug.log(level: 192) { "arrive -> disengage" }
        stepper.dispatch!.disengageGrid()
    }

    func graze(_ manna: Manna) {
        stepper.cFoodHits += 1

        manna.harvest { mannaContent in
            if let mc = mannaContent { self.stepper.metabolism.eat(mc) }
            Debug.log(level: 192) { "graze -> disengage" }
            self.stepper.dispatch!.disengageGrid()
        }
    }
}
