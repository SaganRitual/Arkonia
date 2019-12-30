import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    static let dispatchQueue = DispatchQueue(
        label: "ak.funge.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    override func launch() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("Funge \(six(st.name))", level: 71)
        Debug.debugColor(st, .yellow, .yellow)
        WorkItems.checkSpawnability(st) { self.fungeRoute($0, $1) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, _) = scratch?.getKeypoints() else { fatalError() }

        if !isAlive  { dp.apoptosize(); return }
        if !canSpawn { dp.plot(); return }

        dp.spawn()
    }
}

extension WorkItems {
    typealias OnComplete1Int = (Int) -> Void
    typealias OnComplete1TimeInterval = (TimeInterval) -> Void
    typealias OnComplete2p = (Bool, Bool) -> Void

    static func checkSpawnability(_ stepper: Stepper, _ onComplete: @escaping OnComplete2p) {

        func a()           { getWorldClock(b) }
        func b(_ now: Int) { getAge(of: stepper.name, at: now, c) }
        func c(_ age: Int) { tickLife(of: stepper, to: age, d) }

        func d(_ isAlive: Bool, _ canSpawn: Bool) { onComplete(isAlive, canSpawn) }

        a()
    }

    static func getAge(
        of arkon: String, at currentTime: Int, _ onComplete: @escaping OnComplete1Int
    ) {
        Census.dispatchQueue.async(flags: .barrier) {
            let age = Census.getAge(of: arkon, at: currentTime)
            onComplete(age)
        }
    }

    static func getWorldClock(_ onComplete: @escaping OnComplete1Int) {
        Clock.dispatchQueue.async { onComplete(Clock.shared!.worldClock) }
    }

    private static func tickLife(
        of stepper: Stepper, to age: Int, _ onComplete: @escaping OnComplete2p
    ) {
        Funge.dispatchQueue.async {
            let isAlive = stepper.metabolism.fungeProper(
                age: age, stillCounter: stepper.dispatch.scratch.stillCounter
            )

            let canSpawn = stepper.canSpawn()

            onComplete(isAlive, canSpawn)
        }
    }
}

extension Metabolism {
    func fungeProper(age: Int, stillCounter: CGFloat) -> Bool {
        let joulesNeeded = Arkonia.fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let grace: CGFloat = (age < Arkonia.noCostChildhoodDuration) ? 1 : 0
        let oxygenCost: CGFloat = 0.005 * grace
        let ratchet = CGFloat(1 + Int(stillCounter * 100) / 5)
        let stillnessCost: CGFloat = (pow(1.01, stillCounter) - 1) * grace * ratchet

        oxygenLevel -= oxygenCost + stillnessCost

        Log.L.write(
            "fungeProper:" +
            " mass \(String(format: "%-2.6f", mass))," +
            " w/d \(String(format: "%-2.6f", joulesNeeded))" +
            " still \(String(format: "%03f", stillCounter))" +
            " cost \(String(format: "%-2.6f", stillnessCost))" +
            " O2 \(String(format: "%-3.2f%%", oxygenLevel * 100))" +
            " cost \(String(format: "%-2.6f", oxygenCost))" +
            " energy \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
            " level \(String(format: "%-2.6f", fungibleEnergyContent))" +
            " cap \(String(format: "%-2.6f", fungibleEnergyCapacity))\n"
            , level: 68
        )

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
