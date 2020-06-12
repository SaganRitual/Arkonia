import Foundation

struct JumpSpec {
    let fromCell: SensorPadCell
    let toCell: SensorPadCell

    let distanceInCells: CGFloat
    let speedAsPercentage: CGFloat

    let distanceMeters: CGFloat
    let durationSeconds: TimeInterval
    let speedMetersPerSec: CGFloat

    init(
        _ fromCell: SensorPadCell, _ toCell: SensorPadCell, _ speedAsPercentage: CGFloat
    ) {
        self.fromCell = fromCell
        self.toCell = toCell

        self.distanceInCells = {
            let fp = fromCell.liveGridCell!.properties.gridPosition.asPoint()
            let tp = (toCell.virtualGridPosition ?? toCell.liveGridCell!.properties.gridPosition).asPoint()

            return fp.distance(to: tp)
        }()

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
