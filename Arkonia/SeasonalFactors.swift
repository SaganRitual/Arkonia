import SwiftUI

class SeasonalFactors: ObservableObject {
    @Published var elapsedTimeRealSeconds: TimeInterval = 0

    var previousSunHeight: CGFloat = 0

    let darknessDurationSeconds: TimeInterval
    let daylightDurationSeconds: TimeInterval
    let dayRatio: TimeInterval
    let nightRatio: TimeInterval
    let secondsPerYear: TimeInterval = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear
    let summerDurationDays: TimeInterval
    let summerRatio: TimeInterval
    let winterDurationDays: TimeInterval
    let winterRatio: TimeInterval

    init() {
        nightRatio = Arkonia.darknessAsPercentageOfDay
        dayRatio = 1 - nightRatio
        daylightDurationSeconds = dayRatio * Arkonia.realSecondsPerArkoniaDay
        darknessDurationSeconds = Arkonia.realSecondsPerArkoniaDay - daylightDurationSeconds

        winterRatio = Arkonia.winterAsPercentageOfYear
        summerRatio = 1 - winterRatio
        summerDurationDays = summerRatio * Arkonia.arkoniaDaysPerYear
        winterDurationDays = Arkonia.arkoniaDaysPerYear - summerDurationDays

        Debug.log { String(format: "%.05f, %.05f", daylightDurationSeconds, darknessDurationSeconds) }
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            self.previousSunHeight = self.sunHeight
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }

    var sunstickHeight: CGFloat {
//        let timeOfYear = elapsedTimeRealSeconds.truncatingRemainder(
//            dividingBy: secondsPerYear
//        )
//
//        let yearFullness = timeOfYear / secondsPerYear
//        let day = yearFullness * Arkonia.arkoniaDaysPerYear
//
//        let normalizedSunstickHeight: TimeInterval
//        if day < TimeInterval.pi / summerDurationDays {
//            normalizedSunstickHeight = sin(winterRatio * TimeInterval.pi * day)
//        } else {
//            normalizedSunstickHeight = sin((day - Arkonia.arkoniaDaysPerYear) * TimeInterval.pi / winterDurationDays)
//        }
//
//        let y = -CGFloat(normalizedSunstickHeight) *
//            (ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight - ArkoniaLayout.DaylightFactorView.sunstickFrameHeight) / 2
//
//        return y
        return 0
    }

    var sunHeight: CGFloat {
        let timeOfDay = elapsedTimeRealSeconds.truncatingRemainder(
            dividingBy: Arkonia.realSecondsPerArkoniaDay
        )

        let c0 = timeOfDay * TimeInterval.pi / daylightDurationSeconds
        let c1 = TimeInterval.pi * (timeOfDay - Arkonia.realSecondsPerArkoniaDay) / darknessDurationSeconds

        let normalizedSunHeight = timeOfDay <= daylightDurationSeconds ? sin(c0) : sin(c1)

        let y = -CGFloat(normalizedSunHeight * Arkonia.realSecondsPerArkoniaDay / 2) * ArkoniaLayout.DaylightFactorView.sunFrameHeight / 2

        Debug.log { String(format: "time %0.5f, n %0.5f, y %.05f", timeOfDay, normalizedSunHeight, y) }

        return y
    }
}
