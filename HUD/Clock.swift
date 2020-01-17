import SpriteKit

class Clock {
    typealias OnComplete1CGFloatp = (CGFloat) -> Void
    typealias OnComplete1Intp = (Int) -> Void

    static var shared: Clock!

    private let timeLimit: TimeInterval? = 5000

    let clockFormatter = DateComponentsFormatter()
    let clockReport: Reportoid
    let foodValueReport: Reportoid
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
        guard let t = timeLimit else { return 0 }
        return min(CGFloat(self.worldClock * 2) / CGFloat(t), 1)
    }

    func tickTheWorld() {
        self.worldClock += 1

        self.clockReport.data.text =
            self.clockFormatter.string(from: TimeInterval(self.worldClock))

        self.foodValueReport.data.text = String(format: "%.2f", (1 - self.getEntropy()) * 100)
    }
}
