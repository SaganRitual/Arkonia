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
    }

    static private func getDistanceMeters(_ distanceInCells: CGFloat) -> CGFloat {
        distanceInCells / RealWorldConversions.cellsPerRealMeter
    }

    static private func getSpeedMetersPerSec(_ speedAsPercentage: CGFloat) -> CGFloat {
        speedAsPercentage * Arkonia.standardSpeedCellsPerSecond / RealWorldConversions.cellsPerRealMeter
    }
}
