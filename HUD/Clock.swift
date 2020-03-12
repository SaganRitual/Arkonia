import SpriteKit

class Clock {
    typealias OnComplete1CGFloatp = (CGFloat) -> Void
    typealias OnComplete1Intp = (Int) -> Void

    static var shared: Clock!

    let clockFormatter = DateComponentsFormatter()
    let clockReport: Reportoid
    let foodValueReport: Reportoid
    var nextRain = Date()
    let nextRainPlot: [TimeInterval] = [
        10, 10, 10, 10, 10, 10,
        20, 20, 10, 20, 20, 10,
        20, 10, 20, 20, 20, 10,
        20, 20, 20, 20, 20, 20,
        30, 20, 20, 30, 20, 20,
        30, 20, 30, 20, 30, 20,
        20, 30, 30, 30, 30, 20,
        20, 20, 20, 20, 20, 20,
        30, 30, 30, 30, 30, 30,
        40, 30, 30, 40, 30, 30,
        30, 30, 30, 30, 30, 30,
        40, 30, 40, 30, 40, 30,
        30, 30, 30, 30, 30, 30,
        40, 40, 40, 40, 40, 40,
        50, 40, 40, 50, 40, 40,
        50, 40, 50, 40, 50, 40,
        40, 40, 40, 40, 40, 40,
        50, 50, 50, 50, 50, 50,
        60, 50, 50, 60, 50, 50,
        60, 50, 60, 50, 60, 50,
        50, 50, 50, 50, 50, 50,
        60, 60, 60, 60, 60, 60,
        70, 60, 60, 70, 60, 60,
        70, 60, 70, 60, 70, 60,
        60, 60, 60, 60, 60, 60,
        70, 70, 70, 70, 70, 70,
        80, 70, 70, 80, 70, 70,
        80, 70, 80, 70, 80, 70,
        70, 70, 70, 70, 70, 70,
        80, 80, 80, 80, 80, 80,
        90, 80, 80, 90, 80, 80,
        90, 80, 90, 80, 90, 80,
        80, 80, 80, 80, 80, 80,
        90, 90, 90, 90, 90, 90
    ]
    var nextRainPlotSS = 0
    var worldClock = 0

    static let dispatchQueue = DispatchQueue(
        label: "ak.clock.q",
        target: DispatchQueue.global(qos: .utility)
    )

    init(_ scene: GriddleScene) {
        clockReport = scene.reportArkonia.reportoid(1)
        foodValueReport = scene.reportArkonia.reportoid(3)

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        Arkonia.tickTheWorld(Clock.dispatchQueue, self.tickTheWorld)
    }

    func entropize(_ energyInJoules: CGFloat = 1, _ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async {
            let freakingUglyFixThis = self.getEntropy()
            let ummWhichIsEntropyHuh = (1 - freakingUglyFixThis)
            onComplete(energyInJoules * ummWhichIsEntropyHuh)
        }
    }

    func getEntropy(_ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async { self.getEntropy(onComplete) }
    }

    private func getEntropy() -> CGFloat {
        guard let t = Arkonia.worldTimeLimit else { return 0 }
        return min(CGFloat(self.worldClock * 2) / CGFloat(t), 1)
    }

    func tickTheWorld() {
        self.worldClock += 1

        let now = Date()
        if self.nextRain < now {
            self.nextRain = now + nextRainPlot[nextRainPlotSS]
            nextRainPlotSS = (nextRainPlotSS + 1) % nextRainPlot.count
        }

        self.clockReport.data.text =
            self.clockFormatter.string(from: TimeInterval(self.worldClock))

        let c = Grid.serialQueue.sync { GridCell.cPhotosynthesizingManna }

        self.foodValueReport.data.text = (Arkonia.worldTimeLimit == nil) ?
            String(format: "% 5d/%3d%", c, Arkonia.cMannaMorsels) :
            String(format: "%.2f%%", (1 - self.getEntropy()) * 100)
    }
}
