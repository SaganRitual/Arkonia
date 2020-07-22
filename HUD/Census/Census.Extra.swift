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

    static func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        var worldClock: TimeInterval = 0

        func a() { Clock.getWorldClock { worldClock = $0; b() } }
        func b() { registerDeath(stepper, worldClock, onComplete) }

        a()
    }

    static func registerDeath(
        _ stepper: Stepper, _ worldTime: TimeInterval, _ onComplete: @escaping () -> Void
    ) {
        Census.dispatchQueue.async {
            Census.shared.registerDeath(stepper, worldTime)
            mainDispatch(onComplete)
        }
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
