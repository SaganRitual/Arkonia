import SpriteKit

extension Census {
    static func registerBirth(
        me: Stepper, myParent: Stepper?,
        _ onComplete: @escaping (Fishday) -> Void
    ) {
        Census.dispatchQueue.async {
            let fishday = Census.shared.registerBirth(me.net.netStructure, myParent)
            MainDispatchQueue.async { onComplete(fishday) }
        }
    }

    static func registerDeath(_ stepper: Stepper, _ onComplete: @escaping () -> Void) {
        var worldClock = 0

        func a() { Clock.getWorldClock { worldClock = $0; b() } }
        func b() { registerDeath(stepper, worldClock, onComplete) }

        a()
    }

    static func registerDeath(
        _ stepper: Stepper, _ worldTime: Int, _ onComplete: @escaping () -> Void
    ) {
        Census.dispatchQueue.async {
            Census.shared.registerDeath(stepper, worldTime)
            onComplete()
        }
    }

}

extension Census {
    private static var worldClock = 0

    func updateReports() {
        seedWorld()
        Census.shared.updateReports(Census.worldClock)

        Census.worldClock += 1
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
