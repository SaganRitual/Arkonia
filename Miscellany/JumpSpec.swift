import Foundation

struct JumpSpec {
    let distanceInCells: CGFloat
    let speedAsPercentage: CGFloat

    let distanceMeters: CGFloat
    let durationSeconds: TimeInterval
    let speedMetersPerSec: CGFloat

    init(_ distanceInCells: CGFloat, _ speedAsPercentage: CGFloat) {
        self.distanceInCells = distanceInCells
        self.speedAsPercentage = speedAsPercentage

        distanceMeters = JumpSpec.getDistanceMeters(distanceInCells)
        speedMetersPerSec = JumpSpec.getSpeedMetersPerSec(speedAsPercentage)

        durationSeconds = TimeInterval(distanceMeters / speedMetersPerSec)
    }

    static private func getDistanceMeters(_ distanceInCells: CGFloat) -> CGFloat {
        distanceInCells / RealWorldConversions.cellsPerRealMeter
    }

    static private func getSpeedMetersPerSec(_ speedAsPercentage: CGFloat) -> CGFloat {
        speedAsPercentage * Arkonia.standardSpeedCellsPerSecond / RealWorldConversions.cellsPerRealMeter
    }
}
