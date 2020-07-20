import SwiftUI

class SeasonalFactors: ObservableObject {
    @Published var elapsedTimeRealSeconds: TimeInterval = 0

    var previousSunHeight: CGFloat = 0

    let darknessDuration: TimeInterval
    let daylightDuration: TimeInterval
    let dayRatio: TimeInterval
    let nightRatio: TimeInterval
    let secondsPerYear: TimeInterval
    let summerDurationDays: TimeInterval
    let summerRatio: TimeInterval
    let winterDurationDays: TimeInterval
    let winterRatio: TimeInterval

    init() {
        nightRatio = Arkonia.darknessAsPercentageOfDay
        dayRatio = 1 - nightRatio
        daylightDuration = 2 / nightRatio
        darknessDuration = Arkonia.realSecondsPerArkoniaDay - daylightDuration

        secondsPerYear = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear
        winterRatio = Arkonia.winterAsPercentageOfYear
        summerRatio = 1 - winterRatio
        summerDurationDays = 2 / (winterRatio * Arkonia.realSecondsPerArkoniaDay)
        winterDurationDays = Arkonia.arkoniaDaysPerYear - summerDurationDays
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            self.previousSunHeight = self.sunHeight
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }

    var sunstickHeight: CGFloat {
        let timeOfYear = elapsedTimeRealSeconds.truncatingRemainder(
            dividingBy: secondsPerYear
        )

        let yearFullness = timeOfYear / secondsPerYear
        let day = yearFullness * Arkonia.arkoniaDaysPerYear
        Debug.log { String(format: "%0.2f", yearFullness) + " " + String(format: "%0.2f", TimeInterval.pi / summerDurationDays) }

        let normalizedSunstickHeight: TimeInterval
        if day < TimeInterval.pi / summerDurationDays {
            normalizedSunstickHeight = sin(winterRatio * TimeInterval.pi * day)
        } else {
            normalizedSunstickHeight = sin((day - Arkonia.arkoniaDaysPerYear) * TimeInterval.pi / winterDurationDays)
        }

        let y = -CGFloat(normalizedSunstickHeight) *
            (ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight - ArkoniaLayout.DaylightFactorView.sunstickFrameHeight) / 2

        return y
    }

    var sunHeight: CGFloat {
        let timeOfDay = elapsedTimeRealSeconds.truncatingRemainder(
            dividingBy: Arkonia.realSecondsPerArkoniaDay
        )

        let normalizedSunHeight: TimeInterval
        if timeOfDay < TimeInterval.pi / daylightDuration {
            normalizedSunHeight = sin(nightRatio * TimeInterval.pi * timeOfDay)
        } else {
            normalizedSunHeight = sin((timeOfDay - Arkonia.realSecondsPerArkoniaDay) * TimeInterval.pi / darknessDuration)
        }

        let y = -CGFloat(normalizedSunHeight) * ArkoniaLayout.DaylightFactorView.sunstickFrameHeight / 2
        return y
    }
}
