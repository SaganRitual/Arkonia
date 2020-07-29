import SwiftUI

class SeasonalFactors: ObservableObject {
    @Published var elapsedTimeRealSeconds: TimeInterval = 0

    // Lets me construct an instance of this struct so I can use its
    // nifty UI calculations for the manna energy budget
    let worldClock: TimeInterval?

    let darknessDurationSeconds: TimeInterval
    let daylightDurationSeconds: TimeInterval
    let dayRatioAtFirstSolstice: TimeInterval = 1 - Arkonia.darknessAsPercentageOfDay
    let diurnalFluctuation: CGFloat = CGFloat(Arkonia.diurnalFluctuation)

    let nightRatio: TimeInterval
    let secondsPerDay: TimeInterval = Arkonia.realSecondsPerArkoniaDay
    let secondsPerYear: TimeInterval = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear
    let seasonalFluctuation: CGFloat = CGFloat(Arkonia.seasonalFluctuation)
    let summerDurationDays: TimeInterval
    let summerRatio: TimeInterval
    let winterDurationDays: TimeInterval
    let winterRatio: TimeInterval

    init(_ worldClock: TimeInterval? = nil) {
        nightRatio = Arkonia.darknessAsPercentageOfDay
        daylightDurationSeconds = dayRatioAtFirstSolstice * Arkonia.realSecondsPerArkoniaDay
        darknessDurationSeconds = Arkonia.realSecondsPerArkoniaDay - daylightDurationSeconds

        winterRatio = Arkonia.winterAsPercentageOfYear
        summerRatio = 1 - winterRatio
        summerDurationDays = summerRatio * Arkonia.arkoniaDaysPerYear
        winterDurationDays = Arkonia.arkoniaDaysPerYear - summerDurationDays

        self.worldClock = worldClock
    }

    var currentYear: Int { Int(floor(myTime / secondsPerYear)) }

    var elapsedDaysThisYear: TimeInterval {
        elapsedSecondsThisYear / Arkonia.realSecondsPerArkoniaDay
    }

    var elapsedSecondsThisYear: TimeInterval { myTime - elapsedYearsToSeconds  }
    var elapsedSecondsToday: TimeInterval { elapsedSecondsThisYear.truncatingRemainder(dividingBy: Arkonia.realSecondsPerArkoniaDay) }
    var elapsedYearsToSeconds: TimeInterval { TimeInterval(currentYear) * secondsPerYear }

    var myTime: TimeInterval { self.worldClock ?? self.elapsedTimeRealSeconds }

    // Many, many thanks to Alexander and the crowd at math.stackexchange
    // https://math.stackexchange.com/users/12952/alexander-gruber
    // https://math.stackexchange.com/questions/3766767/is-there-a-simple-ish-function-for-modeling-seasonal-changes-to-day-night-durati
    var diurnalCurve: CGFloat { CGFloat(sin(
        2 * TimeInterval.pi * elapsedSecondsToday * secondsPerDay / secondsPerYear
    ))}

    var seasonalCurve: CGFloat { CGFloat(sin(
        (Double.tau * elapsedSecondsThisYear) / secondsPerYear
    ))}

    var temperature: CGFloat {
        ((seasonalFluctuation * seasonalCurve) + (diurnalFluctuation * diurnalCurve)) / 2
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }
}
