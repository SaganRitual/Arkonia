import SpriteKit

extension Census {
    static func registerBirth(
        me: Stepper, myParent: Stepper?,
        _ onComplete: @escaping (Fishday) -> Void
    ) {
        var worldClock = 0

        func a() { Clock.getWorldClock { worldClock = Int($0); b() } }
        func b() { Census.dispatchQueue.async(execute: c) }
        func c() {
            let cNeurons = Census.shared.registerBirth(me.net.netStructure, myParent)
            let fishday = Fishday(currentTime: worldClock, cNeurons: cNeurons)
            mainDispatch { onComplete(fishday) }
        }

        a()
    }
}

extension Census {
    func updateReports() {
        seedWorld()
        Clock.getWorldClock { worldClock in
            Census.dispatchQueue.async { Census.shared.updateReports(Int(worldClock)) }
        }
    }

    func seedWorld() {
        if populated == false {
            for _ in 0..<Arkonia.initialPopulation {
                Debug.log(level: 205) { "Spawn ex nihilo" }
                Stepper.makeNewArkon(nil)
            }
            populated = true
        }
    }
}
