import SwiftUI

class SeasonalFactors: ObservableObject {
    @Published var elapsedTimeRealSeconds: TimeInterval = 0

    enum Formula { case johnathanZ, simpleSineAddition }
    let formula: Formula

    let annualCyclePeriodSeconds: TimeInterval =
        Arkonia.diurnalCyclePeriodSeconds * Arkonia.annualCyclePeriodDiurnalPeriods

    let daysPerYear = Arkonia.annualCyclePeriodSeconds / Arkonia.diurnalCyclePeriodSeconds
    let diurnalFluctuation: TimeInterval = TimeInterval(Arkonia.diurnalFluctuation)

    let secondsPerDay: TimeInterval = Arkonia.diurnalCyclePeriodSeconds
    let secondsPerYear: TimeInterval = Arkonia.annualCyclePeriodSeconds
    let seasonalFluctuation: TimeInterval = TimeInterval(Arkonia.seasonalFluctuation)
    let summerDurationDays: TimeInterval
    let summerRatio: TimeInterval
    let winterDurationDays: TimeInterval
    let winterRatio: TimeInterval

    init(_ formula: Formula = .simpleSineAddition) {
        self.formula = formula
        winterRatio = Arkonia.winterAsPercentageOfYear
        summerRatio = 1 - winterRatio
        summerDurationDays = summerRatio * Arkonia.annualCyclePeriodDiurnalPeriods
        winterDurationDays = Arkonia.annualCyclePeriodDiurnalPeriods - summerDurationDays
    }

    // Many, many thanks to Alexander and the crowd at math.stackexchange
    // https://math.stackexchange.com/users/12952/alexander-gruber
    // https://math.stackexchange.com/questions/3766767/is-there-a-simple-ish-function-for-modeling-seasonal-changes-to-day-night-durati
    var annualCurve: TimeInterval {
        return sin(TimeInterval.tau * elapsedTimeRealSeconds / annualCyclePeriodSeconds)
    }

    var currentYear: Int { Int(floor(myTime / secondsPerYear)) }
    var dayCompletionPercentage: TimeInterval { elapsedSecondsToday / secondsPerDay }

    var diurnalCurve: TimeInterval {
        switch formula {
        case .simpleSineAddition:
            return sin(
                TimeInterval.tau * elapsedTimeRealSeconds *
                secondsPerDay / secondsPerYear *
                (daysPerYear / secondsPerDay)
            )

        case .johnathanZ:
            let angularMeasureForDayOfYear = elapsedTimeRealSeconds / annualCyclePeriodSeconds
            let axialTilt: TimeInterval = 23   // Approx 23 degrees
            let latitude: TimeInterval = 45    // 45th meridian
            let mysteryNumber: TimeInterval = angularMeasureForDayOfYear - 5 * TimeInterval.pi * elapsedTimeRealSeconds / 60
            let fivePiOver4 = 5 * TimeInterval.pi / 4

            return TimeInterval.pi * acos(
                -(sin(axialTilt) * sin(latitude) + cos(axialTilt) * cos(latitude) * cos(mysteryNumber)) *
                cos(angularMeasureForDayOfYear) - sin(angularMeasureForDayOfYear) *
                sin(mysteryNumber) * cos(latitude)
            ) / fivePiOver4
        }
    }

    var elapsedDaysThisYear: TimeInterval {
        elapsedSecondsThisYear / Arkonia.diurnalCyclePeriodSeconds
    }

    var elapsedSecondsThisYear: TimeInterval { myTime - elapsedYearsToSeconds  }

    var elapsedSecondsToday: TimeInterval {
        elapsedSecondsThisYear.truncatingRemainder(dividingBy: secondsPerDay)
    }

    var elapsedYearsToSeconds: TimeInterval {
        TimeInterval(currentYear) * secondsPerYear
    }

    var myTime: TimeInterval { self.elapsedTimeRealSeconds }

    var seasonalCurve: TimeInterval { TimeInterval(Arkonia.winterSolsticeDaylightPercentage) * annualCurve }

    var temperatureCurve: CGFloat {
        let t:  CGFloat = 0.5 * CGFloat(annualCurve + diurnalCurve) +
                CGFloat(Arkonia.winterSolsticeDaylightPercentage * annualCurve)

        return t / 1.5  // Where does this come from?
    }

    var yearCompletionPercentage: TimeInterval { elapsedSecondsThisYear / secondsPerYear }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }
}
