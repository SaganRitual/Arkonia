import SpriteKit
import SwiftUI

class Clock {
    static var shared = Clock()

    let clockFormatter = DateComponentsFormatter()
//    let clockReport: Reportoid
//    let foodValueReport: Reportoid
    var isRunning = false
    private(set) var worldClock = TimeInterval(0)

    let seasonalFactors = SeasonalFactors()

    static let dispatchQueue = DispatchQueue(
        label: "ak.clock.q",
        target: DispatchQueue.global()
    )

    init() {
//        clockReport = scene.reportArkonia.reportoid(1)
//        foodValueReport = scene.reportArkonia.reportoid(3)
//
//        clockFormatter.allowedUnits = [.hour, .minute, .second]
//        clockFormatter.allowsFractionalUnits = true
//        clockFormatter.unitsStyle = .positional
//        clockFormatter.zeroFormattingBehavior = .pad

        isRunning = true
        tickTheWorld()
    }

    func getEntropy(_ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async {
            self.getEntropy { e in mainDispatch { onComplete(e) } }
        }
    }

    func getEntropy() -> CGFloat {
        guard let t = Arkonia.worldTimeLimit else { return 0 }
        return min(CGFloat(self.worldClock * 2) / CGFloat(t), 1)
    }

    static func getWorldClock(_ onComplete: @escaping (TimeInterval) -> Void) {
        Clock.dispatchQueue.async {
            let c = Clock.shared.worldClock
            onComplete(c)
        }
    }

    static func stop() { Clock.shared.isRunning = false }

    func tickTheWorld() {
        guard isRunning else { return }

        let delay = 1 / Arkonia.updateFrequencyHertz
        self.worldClock += delay
        seasonalFactors.update(self.worldClock)

        Clock.dispatchQueue.asyncAfter(deadline: .now() + delay, execute: tickTheWorld)

//        self.clockReport.data.text =
//            self.clockFormatter.string(from: TimeInterval(self.worldClock))

//        var cPhotosynthesizingManna = 0
//        var cDeadManna = 0

//        func a() { MannaCannon.mannaPlaneQueue.async(execute: b) }

//        func b() {
//            cPhotosynthesizingManna = MannaCannon.shared.cPhotosynthesizingManna
//            cDeadManna = MannaCannon.shared.cDeadManna
//            c()
//        }

//        func c() { Clock.dispatchQueue.async(execute: d) }

//        func d() {
//            self.foodValueReport.data.text
//                = (Arkonia.worldTimeLimit == nil)
//
//                ? String(
//                    format: "% 5d/%3d%",
//                    cPhotosynthesizingManna,
//                    // cPlantedManna is set at startup and never read afterward
//                    MannaCannon.shared.cPlantedManna - cDeadManna
//                )
//
//                : String(format: "%.2f%%", (1 - self.getEntropy()) * 100)
//        }

//        a()
    }
}
