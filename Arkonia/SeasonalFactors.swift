import SwiftUI

class SeasonalFactors: ObservableObject {
    @Published var elapsedTimeRealSeconds: TimeInterval = 0

    // Lets me construct an instance of this struct so I can use its
    // nifty UI calculations for the manna energy budget
    let worldClock: TimeInterval?

    let darknessDurationSeconds: TimeInterval
    let daylightDurationSeconds: TimeInterval
    let dayRatio: TimeInterval
    let nightRatio: TimeInterval
    let secondsPerYear: TimeInterval = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear
    let summerDurationDays: TimeInterval
    let summerRatio: TimeInterval
    let winterDurationDays: TimeInterval
    let winterRatio: TimeInterval

    init(_ worldClock: TimeInterval? = nil) {
        nightRatio = Arkonia.darknessAsPercentageOfDay
        dayRatio = 1 - nightRatio
        daylightDurationSeconds = dayRatio * Arkonia.realSecondsPerArkoniaDay
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

    var myTime: TimeInterval { self.worldClock ?? self.elapsedTimeRealSeconds}

    var normalizedSunHeight: CGFloat {
        let secondsPerYear = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear

        let diurnalCurve = sin(
            2 * TimeInterval.pi * elapsedSecondsThisYear *
                Arkonia.realSecondsPerArkoniaDay / secondsPerYear
        )

        return CGFloat(diurnalCurve)
    }

    var normalizedSunstickHeight: CGFloat {
        let dayRatio = 1 - Arkonia.darknessAsPercentageOfDay
        let secondsPerYear = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear

        let seasonalCurve = sin(
            (2 * elapsedSecondsThisYear * dayRatio * dayRatio) / secondsPerYear
        )

        return CGFloat(seasonalCurve)
    }

    var sunHeight: CGFloat {
        let a = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        let b = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        return normalizedSunHeight * a / b
    }

    var sunstickHeight: CGFloat {
        let a = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        let b = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        return normalizedSunstickHeight * (1 - a / b)
    }

    var temperature: CGFloat { -(sunstickHeight + sunHeight) }

    var normalizedTemperature: CGFloat {
        -(normalizedSunstickHeight + normalizedSunHeight) / 2
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }
}
