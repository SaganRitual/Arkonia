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
    }

    func update(_ officialTime: TimeInterval) {
        DispatchQueue.main.async {
            self.previousSunHeight = self.sunHeight
            Clock.shared.seasonalFactors.elapsedTimeRealSeconds = officialTime
        }
    }

    var sunstickHeight: CGFloat {
        let timeOfYearSeconds = elapsedTimeRealSeconds.truncatingRemainder(
            dividingBy: secondsPerYear
        )

        let timeOfYearDays = timeOfYearSeconds / Arkonia.realSecondsPerArkoniaDay

        let c0 = timeOfYearDays * TimeInterval.pi / summerDurationDays
        let c1 = TimeInterval.pi * (timeOfYearDays - Arkonia.arkoniaDaysPerYear) / winterDurationDays

        let normalizedSunstickHeight = timeOfYearDays <= summerDurationDays ? sin(c0) : sin(c1)

        let a = ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
        let b = ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
        let y = -CGFloat(normalizedSunstickHeight) * (a - b) / 2

        return y
    }

    var sunHeight: CGFloat {
        let timeOfDay = elapsedTimeRealSeconds.truncatingRemainder(
            dividingBy: Arkonia.realSecondsPerArkoniaDay
        )

        let c0 = timeOfDay * TimeInterval.pi / daylightDurationSeconds
        let c1 = TimeInterval.pi * (timeOfDay - Arkonia.realSecondsPerArkoniaDay) / darknessDurationSeconds

        let normalizedSunHeight = timeOfDay <= daylightDurationSeconds ? sin(c0) : sin(c1)

        let y = -CGFloat(normalizedSunHeight * Arkonia.realSecondsPerArkoniaDay / 2) * ArkoniaLayout.DaylightFactorView.sunFrameHeight / 2

        return y
    }
}
