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
            World.stats.getStats(partB)
        }

        func partB(_ stats: World.StatsCopy) {
            self.clockReport.data.text =
                self.clockFormatter.string(from: TimeInterval(stats.currentTime))

            var entropy: TimeInterval {
//                guard let t = timeLimit else { return 0 }
//                return min(gameAge / t, 1.0)

                return 0.0  // No entropy
            }

            let percentage = (1 - entropy) * 100

            self.foodValueReport.data.text = String(format: "%.2f", percentage)
            partC()
        }

        func partC() {
            Grid.shared.serialQueue.asyncAfter(
                deadline: DispatchTime.now() + 1, execute: partA
            )
        }

        partA()
    }

}
