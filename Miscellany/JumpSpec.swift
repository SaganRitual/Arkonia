import Foundation

struct JumpSpec {
    // fromCellPosition == nil means we don't jump, in which case, toCellPosition
    // is just our current position
    let fromCell: IngridCellDescriptor?
    let toCell: IngridCellDescriptor

    let distanceInCells: CGFloat
    let speedAsPercentage: CGFloat

    let distanceMeters: CGFloat
    let durationSeconds: TimeInterval
    let speedMetersPerSec: CGFloat

    static var noJump = JumpSpec()

    init(_ fromCell: IngridCellDescriptor?, _ toCell: IngridCellDescriptor, _ speedAsPercentage: CGFloat) {
        self.fromCell = fromCell
        self.toCell = toCell

        self.distanceInCells = {
            guard let fc = fromCell else { return 0 }

            let fp = fc.cell!.gridPosition.asPoint()
            let tp = toCell.cell!.gridPosition.asPoint()

            Debug.log(level: 192) { "JumpSpec from \(fp) to \(tp), vp \(toCell.virtualScenePosition ?? CGPoint.zero)" }

            // In case we need to teleport to the other side, asteroids-style
            if let vp = toCell.virtualScenePosition { return fp.distance(to: vp) }

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

    private init() {
        fromCell = nil
        toCell = IngridCellDescriptor()
        distanceInCells = 0
        speedAsPercentage = 0
        distanceMeters = 0
        durationSeconds = 0
        speedMetersPerSec = 0
    }

    static private func getDistanceMeters(_ distanceInCells: CGFloat) -> CGFloat {
        distanceInCells / RealWorldConversions.cellsPerRealMeter
    }

    static private func getSpeedMetersPerSec(_ speedAsPercentage: CGFloat) -> CGFloat {
        speedAsPercentage * Arkonia.standardSpeedCellsPerSecond / RealWorldConversions.cellsPerRealMeter
    }
}
