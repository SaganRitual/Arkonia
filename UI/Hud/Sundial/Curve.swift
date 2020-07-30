import Foundation
import SwiftUI

class Curve {
    enum Formula { case johnathanZ, simpleSineAddition }

    let annualCyclePeriodSeconds: Double
    let diurnalCyclePeriodSeconds: Double = 5
    let annualCyclePeriodDiurnalPeriods: Double = 5
    let formula: Formula
    let winterSolsticeDaylightPercentage: Double = 0.5
    let worldClock: TimeInterval

    var temperatureCurve: Double {
        let t = 0.5 * (annualCurve + diurnalCurve) +
                Double(winterSolsticeDaylightPercentage) * annualCurve

        return t / 1.5
    }

    var currentYear: Int { Int(floor(worldClock / annualCyclePeriodSeconds)) }

    var elapsedSecondsThisYear: TimeInterval { worldClock - elapsedYearsToSeconds  }
    var elapsedSecondsToday: TimeInterval { elapsedSecondsThisYear.truncatingRemainder(dividingBy: diurnalCyclePeriodSeconds) }
    var elapsedYearsToSeconds: TimeInterval { TimeInterval(currentYear) * annualCyclePeriodSeconds }

    var dayCompletionPercentage: Double { elapsedSecondsToday / diurnalCyclePeriodSeconds }
    var yearCompletionPercentage: Double { elapsedSecondsThisYear / annualCyclePeriodSeconds }

    init(_ formula: Formula, _ worldClock: TimeInterval) {
        self.formula = formula
        self.worldClock = worldClock
        annualCyclePeriodSeconds = diurnalCyclePeriodSeconds * annualCyclePeriodDiurnalPeriods
    }

    var annualCurve: Double {
        return sin(Double.tau * worldClock / annualCyclePeriodSeconds)
    }

    var diurnalCurve: Double {
        switch formula {
        case .simpleSineAddition:
            return sin(Double.tau * worldClock * diurnalCyclePeriodSeconds / annualCyclePeriodSeconds)

        case .johnathanZ:
            let t = worldClock
            let angularMeasureForDayOfYear = worldClock / annualCyclePeriodSeconds
            let axialTilt: Double = 23   // Approx 23 degrees
            let latitude: Double = 45    // 45th meridian
            let mysteryNumber: Double = angularMeasureForDayOfYear - 5 * Double.pi * t / 60
            let fivePiOver4 = 5 * Double.pi / 4

            return Double.pi * acos(
                -(sin(axialTilt) * sin(latitude) + cos(axialTilt) * cos(latitude) * cos(mysteryNumber)) *
                cos(angularMeasureForDayOfYear) - sin(angularMeasureForDayOfYear) *
                sin(mysteryNumber) * cos(latitude)
            ) / fivePiOver4
        }
    }
}
