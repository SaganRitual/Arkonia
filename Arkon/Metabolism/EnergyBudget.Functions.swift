import Foundation

extension EnergyBudget {
    static func computeMoveCost(jumpSpeedAsPercentage: CGFloat, distanceInPixels: CGFloat, massKg: CGFloat) -> CGFloat {
        // Trying to make the numbers at least somewhat realistic, in the hopes
        // of making energy budgeting easier to debug, and perhaps easier (not
        // to mention simply having some meaning) to  display on the HUD if I
        // ever feel like it
        let jumpSpeedPixPerSec = jumpSpeedAsPercentage * EnergyBudget.World.standardSpeedPixPerSec

        let jumpSpeedMetersPerSec = jumpSpeedPixPerSec / EnergyBudget.World.pixPerMeter
        let distanceInMeters = distanceInPixels / EnergyBudget.World.pixPerMeter

        // It will take jumpSpeedInMeters * massInKg to reach the target speed
        // at a distance of 1m. That much is real physics. The fudge factor is
        // that we multiply that by distanceInMeters, meaning we're treating it
        // as though we're accelerating to the target speed over 1m, over and
        // over distanceInMeters times. It's special Arkonia-friction, yeah,
        // that's it
        //
        // All this hard thinking had better turn out to have some kind of
        // interesting effect on the way the arkons behave, or I'm demanding a refund
        let force = jumpSpeedMetersPerSec * massKg

        Debug.log(level: 173) {
            "comput: speed \(jumpSpeedAsPercentage) -> \(jumpSpeedMetersPerSec)"
            + ", distance \(distanceInPixels) -> \(distanceInMeters)"
            + ", mass \(massKg)"}

        // W = Fd
        return force * distanceInMeters
    }
}
