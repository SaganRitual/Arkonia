import Foundation

struct SensorSnapshot {
    let sensorSS: CellSensor
    let cellSS: GridCell

    init(_ sensor: CellSensor) {
        self.sensorSS = sensor
        self.cellSS = sensor.liveGridCell
    }
}

struct JumpSpec {
    let from: GridCell
    let to: SensorSnapshot
    let attackYesNo: Bool
    let attackTargetIndex: Int

    let distanceInCells: CGFloat
    let speedAsPercentage: CGFloat

    let distanceMeters: CGFloat
    let durationSeconds: TimeInterval
    let speedMetersPerSec: CGFloat

    init(
        from fromLiveGridCell: GridCell, to: CellSensor,
        speedAsPercentage: CGFloat,
        attackYesNo: Bool, attackTargetIndex: Int
    ) {
        self.from = fromLiveGridCell
        self.to = .init(to)

        self.attackYesNo = attackYesNo
        self.attackTargetIndex = attackTargetIndex

        hardAssert(fromLiveGridCell.properties.gridPosition != to.liveGridCell.properties.gridPosition) { nil }

        self.distanceInCells = {
            let fp = fromLiveGridCell.properties.gridPosition.asPoint()
            let tp = (to.virtualGridPosition ?? to.liveGridCell.properties.gridPosition).asPoint()

            return fp.distance(to: tp)
        }()

        hardAssert(self.distanceInCells > 0) { nil }

        self.speedAsPercentage = speedAsPercentage

        distanceMeters = JumpSpec.getDistanceMeters(distanceInCells)
        speedMetersPerSec = JumpSpec.getSpeedMetersPerSec(speedAsPercentage)

        let visualSpeedScaleNoEffectOnPhysicsCalculations: TimeInterval = 2

        durationSeconds =
            TimeInterval(distanceMeters / speedMetersPerSec) /
            visualSpeedScaleNoEffectOnPhysicsCalculations

//        var dumbassTargetCell: GridCell?
//        let a = (1..<9).first(where: {
//            (dumbassTargetCell, _) = Grid.cellAt(
//                $0, from: Grid.cellAt(self.to.cellSS.properties.gridAbsoluteIndex)
//            )
//
//            return isWithinSensorRange(dumbassTargetCell!.properties.gridPosition) &&
//                isLockedByMe(dumbassTargetCell!) &&
//                hasArkon(dumbassTargetCell!)
//        }) ?? 0
//
//        self.attackTargetIndex = a
//        self.attackYesNo = self.attackTargetIndex > 0
//        Debug.log(level: 221) { a == 0 ? nil : "attack ix \(a), which is cell at \(dumbassTargetCell!.properties.gridPosition)" }
    }

    static private func getDistanceMeters(_ distanceInCells: CGFloat) -> CGFloat {
        distanceInCells / RealWorldConversions.cellsPerRealMeter
    }

    static private func getSpeedMetersPerSec(_ speedAsPercentage: CGFloat) -> CGFloat {
        speedAsPercentage * Arkonia.standardSpeedCellsPerSecond / RealWorldConversions.cellsPerRealMeter
    }
}

//private extension JumpSpec {
//    func getLocalIndexForCell(_ cell: GridCell) -> Int {
//        let fromGridPosition = self.from.properties.gridPosition
//        let offset = abs(cell.properties.gridPosition) - abs(fromGridPosition)
//
//        return GridIndexer.offsetToLocalIndex(offset)
//    }
//
//    func hasArkon(_ cell: GridCell) -> Bool { cell.contents.hasArkon() }
//
//    func isLockedByMe(_ cell: GridCell) -> Bool {
//        let localIndex = getLocalIndexForCell(cell)
//        return self.from.contents.arkon!.sensorPad.theSensors[localIndex].iHaveTheLiveConnection
//    }
//
//    func isWithinSensorRange(_ gridPosition: AKPoint) -> Bool {
//        let offset = gridPosition - from.properties.gridPosition
//        let maxOffset = self.from.contents.arkon!.arkon!.net.netStructure.cSenseRings
//        return abs(offset.x) <= maxOffset  && abs(offset.y) <= maxOffset
//    }
//}
