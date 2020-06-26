import Foundation

extension SensorPad {
    func getNutrition(at localIndex: Int) -> Float {
        // Never look at the hot values in a cell if we don't have the lock for it.
        // We can read the static properties like the scene position, but not
        // the contents like arkons and manna
        guard theSensors[localIndex].iHaveTheLiveConnection else { return 0 }

        let contents = theSensors[localIndex].liveGridCell.contents

        if contents.hasArkon() {
            return contents.arkon!.sensorPad.energyLevel
        }

        if contents.hasManna() {
            return Float(contents.manna!.sprite.getMaturityLevel())
        }

        return 0
    }

    func loadSelector(at localIndex: Int) -> Float {
        // Never look at a cell if we don't have the lock for it. We only
        // ever read/write the variable values through a locked sensor
        // pad cell, or with the whole grid locked in the GridSync mechanism.
        let cell = theSensors[localIndex]

        guard cell.iHaveTheLiveConnection else {
            return GridCellContents.CellContents.invisible.asSenseData()
        }

        return cell.liveGridCell!.contents.contents.asSenseData()
    }
}
