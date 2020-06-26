import SpriteKit

extension Stepper {
    func moveStepper() {
        var fromContents: GridCellContents?
        var toContents: GridCellContents?

        func moveStepper_A() { MainDispatchQueue.async(execute: moveStepper_B) }

        func moveStepper_B() {
            Debug.debugColor(self, .brown, .purple)

            cJumps += 1    // We count it as a jump even if we don't move

            let toLocalIx =   jumpSpec!.to.sensorSS.sensorPadLocalIndex
            let fromAbsIx =   spindle.gridCell.properties.gridAbsoluteIndex
            let toAbsIx =     jumpSpec!.to.sensorSS.liveGridCell.properties.gridAbsoluteIndex

            fromContents = spindle.gridCell.contents
            toContents = jumpSpec!.to.sensorSS.liveGridCell.contents

            Debug.log(level: 213) {
                "moveStepper \(name)"
                + " \(fromContents!.hasArkon())"
                + " localIx \(toLocalIx);"
                + " fromAbsIx \(fromAbsIx)"
                + " \(Grid.cellAt(fromAbsIx).properties.gridPosition)"
                + " \(spindle.gridCell.properties.gridPosition)"
                + " toAbsIx \(toAbsIx)"
                + " \(Grid.cellAt(toAbsIx).properties.gridPosition)"
            }

            hardAssert(jumpSpec!.to.sensorSS.iHaveTheLiveConnection) { "Jumping to blind sensor?" }
            hardAssert(fromContents!.hasArkon()) { "fromWrong" }
            hardAssert(!toContents!.hasArkon())  { "toWrong" }

            // Do we really have the live connection here?
            spindle.move(to: jumpSpec!.to.sensorSS.liveGridCell, iHaveTheLiveConnection: true)

            if toContents!.hasManna() {
                Debug.log(level: 213) { "moveStepper -> arrive" }
                arrive()
                return
            }

            disengageGrid()
        }

        moveStepper_A()
    }
}
