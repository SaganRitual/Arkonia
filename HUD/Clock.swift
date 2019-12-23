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
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .userInitiated)
    )

    init(_ scene: GriddleScene) {
        clockReport = scene.reportArkonia.reportoid(1)
        foodValueReport = scene.reportArkonia.reportoid(3)

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        updateClock()
    }

    func getWorldClock(_ onComplete: @escaping OnComplete1Intp) {
        Clock.dispatchQueue.async { onComplete(self.worldClock) }
    }

    func getEntropy(_ onComplete: @escaping OnComplete1CGFloatp) {
        Clock.dispatchQueue.async { onComplete(self.getEntropy()) }
    }

    private func getEntropy() -> CGFloat {
        guard let t = timeLimit else { return 0 }
        return min(CGFloat(worldClock * 2) / CGFloat(t), 1)
    }

    func updateClock() {
        Clock.dispatchQueue.asyncAfter(deadline: .now() + 1, flags: .barrier) { self.partA() }
    }

    func partA() {
        self.worldClock += 1

        self.clockReport.data.text =
            self.clockFormatter.string(from: TimeInterval(self.worldClock))

        self.foodValueReport.data.text = String(format: "%.2f", (1 - self.getEntropy()) * 100)
        updateClock()
    }
}
