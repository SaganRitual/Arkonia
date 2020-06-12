import SpriteKit

extension Stepper {
    func moveStepper() { MainDispatchQueue.async(execute: moveStepper_) }

    func moveStepper_() {
        Debug.debugColor(self, .brown, .purple)

        cJumps += 1    // We count it as a jump even if we don't move

        let fromLocalIx = jumpSpec!.fromCell.padLocalIndex
        let toLocalIx =   jumpSpec!.toCell.padLocalIndex
        let fromAbsIx = sensorPad.thePadCells[fromLocalIx].liveGridCell!.properties.gridAbsoluteIndex
        let toAbsIx = sensorPad.thePadCells[toLocalIx].liveGridCell!.properties.gridAbsoluteIndex

        let fromContents = sensorPad.thePadCells[fromLocalIx].liveGridCell!.contents
        let toContents = sensorPad.thePadCells[toLocalIx].liveGridCell!.contents

        Debug.log(level: 209) {
            "moveStepper \(name)"
            + " to loc \(toLocalIx);"
            + " from abs \(fromAbsIx)"
            + " to abs \(toAbsIx)"
        }

        hardAssert(fromContents.hasArkon()) { "fromWrong" }
        hardAssert(!toContents.hasArkon()) { "toWrong" }

        sensorPad.moveArkon(to: jumpSpec!.toCell)

        if toContents.hasManna() {
            Debug.log(level: 192) { "moveStepper -> arrive" }
            arrive()
            return
        }

        disengageGrid()
    }
}
