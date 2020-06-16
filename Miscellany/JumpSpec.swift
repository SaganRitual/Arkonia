import Foundation

struct JumpSpec {
    let fromCell: IngridCell
    let toCell: IngridCell

    let toLocalIndex: Int
    let toVirtualScenePosition: CGPoint?

    let distanceInCells: CGFloat
    let speedAsPercentage: CGFloat

    let distanceMeters: CGFloat
    let durationSeconds: TimeInterval
    let speedMetersPerSec: CGFloat

    init(
        _ fromCell: IngridCell, _ toCell: IngridCell, _ toLocalIndex: Int,
        _ toVirtualScenePosition: CGPoint?, _ speedAsPercentage: CGFloat
    ) {
        self.fromCell = fromCell
        self.toCell = toCell
        self.toLocalIndex = toLocalIndex
        self.toVirtualScenePosition = toVirtualScenePosition

        self.distanceInCells = {
            let fp = fromCell.gridPosition.asPoint()
            let tp = toVirtualScenePosition ?? toCell.gridPosition.asPoint()

            Debug.log(level: 197) { "JumpSpec from \(fp) to \(tp) isVirtual \(toVirtualScenePosition != nil)" }

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
