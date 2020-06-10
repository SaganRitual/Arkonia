import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { moveStepper() }

    func moveStepper() {
        Debug.debugColor(stepper, .brown, .purple)

        if let moveFrom = stepper.jumpSpec.fromCell?.absoluteIndex {
            let moveTo = stepper.jumpSpec.toCell.absoluteIndex
            let contents = Ingrid.shared.getContents(in: moveTo)

            Ingrid.shared.arkons.moveArkon(
                stepper, fromIndex: moveFrom, toIndex: moveTo
            )

            if contents == .arkon || contents == .manna {
                Debug.log(level: 192) { "moveStepper -> arrive" }
                stepper.dispatch!.arrive()
                return
            }
        }

        Debug.log(level: 192) { "moveStepper -> disengage" }
        stepper.dispatch!.disengageGrid()
    }
}
