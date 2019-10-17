import SpriteKit

class Clock {
    let clockFormatter = DateComponentsFormatter()
    let clockReport: Reportoid
    let foodValueReport: Reportoid
    let timeZero = Date()

    init(_ scene: GriddleScene) {
        clockReport = scene.reportArkonia.reportoid(1)
        foodValueReport = scene.reportArkonia.reportoid(3)

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        updateClock()
    }

    func updateClock() {
        func partA() {
            World.shared.getAges(callback: partB)
        }

        func partB(
            maxLivingArkonAge: TimeInterval,
            highWaterArkonAge: TimeInterval
        ) {
            let gameAge = Date().timeIntervalSince(timeZero)
            self.clockReport.data.text = self.clockFormatter.string(from: gameAge)

            var entropy: TimeInterval {
//                guard let t = timeLimit else { return 0 }
//                return min(gameAge / t, 1.0)

                return 0.0  // No entropy
            }

            let percentage = (1 - entropy) * 100

            self.foodValueReport.data.text = String(format: "%.2f", percentage)

            let delay = TimeInterval.random(in: 0.25...1.0)
            asyncQueue.asyncAfter(deadline: DispatchTime.now() + delay, execute: partA)
        }

        partA()
    }

}
