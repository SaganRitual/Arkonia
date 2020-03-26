import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { Grid.serialQueue.async(execute: moveStepper) }

    func moveStepper() {
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        Debug.log(level: 154) { "MoveStepper \(six(stepper.name))" }

        shuttle.move()
        stepper.previousShiftOffset = stepper.gridCell.gridPosition
        Debug.log(level: 154) { "set3 \(six(stepper.name)) gridCell before \(stepper.gridCell.gridPosition)" }
//        let other = stepper.gridCell.sprite?.getStepper(require: false)

        stepper.gridCell = shuttle.toCell?.gridCell
//        print                ("MoveStepper"
//        + " stepper \(six(stepper.name))"
//        + " sprite \(six(stepper.sprite?.name))"
//        + " gridCell \(stepper.gridCell.gridPosition)"
//        + " lock owner \(six(stepper.gridCell.ownerName))"
//        + " cell occupier sprite \(six(stepper.gridCell.sprite?.name))"
//        + " other stepper \(six(other?.name))"
//        + " other sprite \(six(other?.sprite?.name))"
//        + " other gridCell \(other?.gridCell.gridPosition ?? AKPoint(x: 4242, y: -4242))")

        assert(stepper.gridCell.contents == .arkon && stepper.gridCell.sprite?.name ?? "nothing" == stepper.name)

        self.postMove(shuttle)
    }
}

extension MoveStepper {
    func postMove(_ shuttle: CellShuttle) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }

        Debug.log(level: 154) { "postMove" }
        let isEdible = shuttle.consumedContents == .arkon || st.gridCell.mannaSprite != nil

        if shuttle.didMove && isEdible {
            Debug.log(level: 154) { "post move to arrive" }
            assert(shuttle.toCell?.contents == .arkon || shuttle.toCell?.contents == .nothing)
            dp.arrive()
            return
        }

        Debug.log(level: 154) { "post move to releaseshuttle" }
        dp.releaseShuttle()
    }
}
