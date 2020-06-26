import Foundation

extension SensorPad {
    func getFirstTargetableCell(startingAt targetLocalIndex: Int) -> CellSensor? {
        var debugLogString = "["
        defer {
            debugLogString += "]"
            Debug.log(level: 214) { "\(spindle.arkon.name) " + debugLogString }
        }
        var separator = ""
        for ss_ in 0..<theSensors.count {
            defer { separator = ", " }
            debugLogString += separator

            let localIndex = (ss_ + targetLocalIndex) % theSensors.count
            debugLogString += "\(localIndex)"

            // If the target cell isn't available (meaning we couldn't
            // see it when we tried to lock it, because someone had that
            // cell locked already), then find the first visible cell after
            // our target. If that turns out to be the cell I'm sitting in,
            // skip it and look for the next after that. I've decided to
            // jump already, so, I'll jump.
            //
            // No particular reason for this policy. We could just as easily
            // stay here. Maybe put it under genetic control and see if it
            // has any effect
            if localIndex == 0 { debugLogString += " -> center"; continue }

            // If we don't get a core cell, it's because we don't have the
            // cell locked (someone else has it), so we can't jump there
            if !theSensors[localIndex].iHaveTheLiveConnection { debugLogString += " -> blind"; continue }

            let contents = theSensors[localIndex].liveGridCell!.contents

            // Of course, don't forget that we can't squeeze into the
            // same cell as another arkon, at least not for now
            if contents.hasArkon() { debugLogString += " -> \(spindle.arkon.name)"; continue }

            debugLogString += " -> \(localIndex)"
            return theSensors[localIndex]
        }

        debugLogString += "--- nothing found!"
        return nil
    }
}
