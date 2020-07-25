import Foundation

class CellSensor {
    var iHaveTheLiveConnection = false
    var liveGridCell: GridCell!
    let sensorPadLocalIndex: Int
    var virtualGridPosition: AKPoint?

    init(_ sensorPadLocalIndex: Int) { self.sensorPadLocalIndex = sensorPadLocalIndex }

    func engage(with cell: GridCell, virtualPosition vp: AKPoint?, gridIsLocked: Bool) {
        assert(gridIsLocked)

        liveGridCell = cell
        Debug.log(level: 213) { " engage() for cell at \(liveGridCell.properties.gridPosition)" }

        self.iHaveTheLiveConnection = !cell.lock.isLocked
        if self.iHaveTheLiveConnection { cell.lock.isLocked = true }

        self.virtualGridPosition =
            (vp == cell.properties.gridPosition) ? nil : vp

        self.liveGridCell = cell
    }

    func disengage() {
        hardAssert(liveGridCell != nil) { "here it is" }
        Debug.log(level: 219) { "disengage.0 \(liveGridCell.properties.gridPosition)" }
        let iHadTheLiveConnection = self.iHaveTheLiveConnection

        self.iHaveTheLiveConnection = false
        self.virtualGridPosition = nil

        Debug.log(level: 219) { "disengage.1 \(liveGridCell.properties.gridPosition)" }
        if iHadTheLiveConnection {
            Debug.log(level: 219) { "disengage.2 \(liveGridCell.properties.gridPosition)" }
            let cellIsOccupied = liveGridCell.contents.hasArkon()
            Debug.log(level: 219) { "disengage.3 \(liveGridCell.properties.gridPosition)" }
            liveGridCell.lock.releaseLock(cellIsOccupied)
            Debug.log(level: 219) { "disengage.4 \(liveGridCell.properties.gridPosition)" }
        }
        Debug.log(level: 219) { "disengage.5 \(liveGridCell.properties.gridPosition)" }
    }
}
