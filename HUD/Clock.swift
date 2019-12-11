import SpriteKit

class Clock {
    let clockFormatter = DateComponentsFormatter()
    let clockReport: Reportoid
    let foodValueReport: Reportoid
    private let timeLimit: TimeInterval? = 5000
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

    func getEntropy() -> CGFloat {
        guard let t = timeLimit else { return 0 }
        return min(CGFloat(World.stats.gameAge * 2) / CGFloat(t), 1)

//        return 0.0  // No entropy
    }

    func updateClock() {
        func partA() {
            World.stats.getStats(partB)
        }

        func partB(_ stats: World.StatsCopy) {
            self.clockReport.data.text =
                self.clockFormatter.string(from: TimeInterval(stats.currentTime))

            let percentage = (1 - getEntropy()) * 100

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
