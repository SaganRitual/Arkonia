import Foundation

struct EnergyBudget {
    static let lengthCellSide:    CGFloat = 1// * oneCm
    static let lengthCellDiag:    CGFloat = sqrt(2 * pow(lengthCellSide, 2))
    static let massUnitInKg:      CGFloat = 0.001
    static let oneCm:             CGFloat = 0.01    // In meters
    static let oneGram:           CGFloat = 0.001   // In kg
    static let o2costPerJoule:    CGFloat = 2.5
}

// MARK: Base costs
// The costs of just sitting doing nothing, per tick

extension EnergyBudget {
    static let joulesCostPerOrganCapacity:     CGFloat = 1
    static let joulesCostPerBodyMass:          CGFloat = 1
    static let joulesCostPerAccessoryStrength: CGFloat = 1
}

extension EnergyBudget {
    static func computeMoveCost(jumpSpeedAsPercentage: CGFloat, distanceInPixels: CGFloat, massInGrams: CGFloat) -> CGFloat {
        // Trying to make the numbers at least somewhat realistic, in the hopes
        // of making energy budgeting easier to debug, and perhaps easier (not
        // to mention simply having some meaning) to  display on the HUD if I
        // ever feel like it
        let jumpSpeedInPix = jumpSpeedAsPercentage * Arkonia.arkonStandardSpeedPixPerSec

        let jumpSpeedInMeters = jumpSpeedInPix * EnergyBudget.oneCm
        let distanceInMeters = distanceInPixels * EnergyBudget.oneCm

        let massInKg = EnergyBudget.oneGram * massInGrams

        // It will take jumpSpeedInMeters * massInKg to reach the target speed
        // at a distance of 1m. That much is real physics. The fudge factor is
        // that we multiply that by distanceInMeters, meaning we're treating it
        // as though we're accelerating to the target speed over 1m, over and
        // over distanceInMeters times. It's special Arkonia-friction, yeah,
        // that's it
        //
        // All this hard thinking had better turn out to have some kind of
        // interesting effect on the way the arkons behave, or I'm demanding a refund
        let force = jumpSpeedInMeters * massInKg

        // W = Fd
        return force * distanceInMeters

//        let netJoules = scratch.stepper.metabolism.x.withdrawEnergy(work)
//
//        let netJoules_ = String(format: "%3.5f", netJoules)
//        let distanceInMeters_ = String(format: "%3.5f", distanceInMeters)
//        let massInKg_ = String(format: "%3.5f", massInKg)
//        let jumpSpeedInMeters_ = String(format: "%3.5f", jumpSpeedInMeters)
//
//        Debug.log(level: 174) {
//            "Need \(netJoules_) joules to move \(massInKg_) kg \(distanceInMeters_)m at \(jumpSpeedInMeters_) m/sec"
//        }
//
//        return netJoules
    }
}
