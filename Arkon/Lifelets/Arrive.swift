import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        Debug.debugColor(scratch.stepper, .brown, .green)
        if scratch.stepper.gridCell.manna != nil { graze(); return }

        scratch.dispatch!.releaseShuttle()
    }

    func graze() {
        guard let manna = scratch.stepper.gridCell.manna else { fatalError() }
        Debug.log(level: 174) { "graze \(scratch.stepper.name)" }

        manna.harvest { mannaContent in
            if let mc = mannaContent { self.scratch.stepper.metabolism.eat(mc) }
            self.scratch.dispatch!.releaseShuttle()
        }
    }
}
