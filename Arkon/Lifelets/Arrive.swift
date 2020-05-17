import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        if scratch.stepper.gridCell.manna != nil { graze(); return }

        scratch.dispatch!.releaseShuttle()
    }

    func graze() {
        guard let manna = scratch.stepper.gridCell.manna else { fatalError() }
        Debug.log(level: 174) { "graze \(scratch.stepper.name)" }

        manna.harvest { _ /*nutrition*/ in
            self.scratch.stepper.metabolism.eat(/*nutrition*/)
            self.scratch.dispatch!.releaseShuttle()
        }
    }
}
