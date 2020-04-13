import SpriteKit

class Clock {
    typealias OnComplete1CGFloatp = (CGFloat) -> Void
    typealias OnComplete1Intp = (Int) -> Void

    static var shared: Clock!

    let clockFormatter = DateComponentsFormatter()
    let clockReport: Reportoid
    let foodValueReport: Reportoid
    private(set) var worldClock = 0

    static let dispatchQueue = DispatchQueue(
        label: "ak.clock.q", attributes: .concurrent,
        target: DispatchQueue.global()
    )

    init(_ scene: ArkoniaScene) {
        clockReport = scene.reportArkonia.reportoid(1)
        foodValueReport = scene.reportArkonia.reportoid(3)

        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad

        Arkonia.tickTheWorld(Clock.dispatchQueue, self.tickTheWorld)
    }

    func entropize(_ energyInJoules: CGFloat = 1, _ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async { onComplete(energyInJoules * (1 - self.getEntropy())) }
    }

    func getEntropy(_ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async { self.getEntropy(onComplete) }
    }

    func getEntropy() -> CGFloat {
        guard let t = Arkonia.worldTimeLimit else { return 0 }
        return min(CGFloat(self.worldClock * 2) / CGFloat(t), 1)
    }

    static func getWorldClock(_ onComplete: @escaping (Int) -> Void) {
        Clock.dispatchQueue.async { onComplete(Clock.shared!.worldClock) }
    }

    func tickTheWorld() {
        self.worldClock += 1

        self.clockReport.data.text =
            self.clockFormatter.string(from: TimeInterval(self.worldClock))

        var cPhotosynthesizingManna = 0
        var cDeadManna = 0

        func a() { MannaCannon.mannaPlaneQueue.async(execute: b) }

        func b() {
            cPhotosynthesizingManna = MannaCannon.shared!.cPhotosynthesizingManna
            cDeadManna = MannaCannon.shared!.cDeadManna
            c()
        }

        func c() { Clock.dispatchQueue.async(execute: d) }

        func d() {
            self.foodValueReport.data.text
                = (Arkonia.worldTimeLimit == nil)

                ? String(
                    format: "% 5d/%3d%",
                    cPhotosynthesizingManna,
                    // cPlantedManna is set at startup and never read afterward
                    MannaCannon.shared!.cPlantedManna - cDeadManna
                )

                : String(format: "%.2f%%", (1 - self.getEntropy()) * 100)
        }

        a()
    }
}
