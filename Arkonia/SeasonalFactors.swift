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
        let c0 = elapsedSecondsToday * TimeInterval.pi / daylightDurationSeconds
        let c1 = TimeInterval.pi * (elapsedSecondsToday - Arkonia.realSecondsPerArkoniaDay) / darknessDurationSeconds

        return CGFloat(elapsedSecondsToday <= daylightDurationSeconds ? sin(c0) : sin(c1))
    }

    var normalizedSunstickHeight: CGFloat {
        let n: TimeInterval

        if elapsedDaysThisYear <= summerDurationDays {

            // Summertime, sun follows the summertime path
            n = elapsedDaysThisYear * TimeInterval.pi / summerDurationDays

        } else {

            // Wintertime path
            n = TimeInterval.pi *
                (elapsedDaysThisYear - Arkonia.arkoniaDaysPerYear) /
                winterDurationDays
        }

        return CGFloat(sin(n))
    }

    var pCurrentDay: TimeInterval {
        elapsedSecondsToday / Arkonia.realSecondsPerArkoniaDay
    }

    var pCurrentYear: TimeInterval {
        elapsedSecondsThisYear / secondsPerYear
    }

    var sunHeight: CGFloat {
        -CGFloat(normalizedSunHeight) * ArkoniaLayout.DaylightFactorView.sunFrameHeight * 2
    }

    var sunstickHeight: CGFloat {
        let a = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        let b = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        return -CGFloat(normalizedSunstickHeight) * (a - b) / 2
    }

    var temperature: CGFloat { -(sunstickHeight + sunHeight) }

    var normalizedTemperature: CGFloat { ntStick + ntSun }

    var ntSun: CGFloat {
        let a = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        let b = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        return normalizedSunHeight * a / b
    }

    var ntStick: CGFloat {
        let a = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        let b = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        return normalizedSunstickHeight * (1 - a / b)
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }
}
