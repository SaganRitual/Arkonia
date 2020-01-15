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
        Debug.log("Funge \(six(st.name))", level: 85)
        Debug.debugColor(st, .yellow, .yellow)
        WorkItems.checkSpawnability(st) { self.fungeRoute($0, $1) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }

        if !isAlive  { Debug.log("FungeRoute1 \(six(st.name))", level: 85); dp.apoptosize(); return }

        st.sprite.setScale(Arkonia.arkonScaleFactor * (1 + st.metabolism.spawnEnergyFullness) / Arkonia.zoomFactor)

        if !canSpawn { Debug.log("FungeRoute2 \(six(st.name))", level: 85); dp.plot(); return }

        Debug.log("FungeRoute3 \(six(st.name))", level: 85)
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
    static var showHeader = true
    func fungeProper(age: Int, stillCounter: CGFloat) -> Bool {
        let joulesNeeded = Arkonia.fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: CGFloat = Arkonia.oxygenCostPerTick
//        let ratchet = CGFloat(1 + Int(stillCounter * 100) / 5)
        let stillnessCost: CGFloat = (pow(1.01, stillCounter) - 1)// * ratchet

        oxygenLevel -= oxygenCost + stillnessCost

        if Metabolism.showHeader {
            Debug.log("             age     mass      w/d    sCost       O2     oCost     O2+s    gFull  gContent  gCapacity", level: 79)
            Metabolism.showHeader = false
        }

        Debug.log(
            "fungeProper:" +
            " \(String(format: "% 3d", age))" +
            " \(String(format: "% 8.3f", mass))" +
            " \(String(format: "% 8.3f", joulesNeeded))" +
            " \(String(format: "% 8.3f", stillnessCost))" +
            " \(String(format: "% 8.3f%%", oxygenLevel * 100))" +
            " \(String(format: "% 8.3f", oxygenCost))" +
            " \(String(format: "% 8.3f", oxygenCost + stillnessCost))" +
            " \(String(format: "% 8.3f%%", fungibleEnergyFullness * 100))" +
            " \(String(format: "% 8.3f", fungibleEnergyContent))" +
            " \(String(format: "% 10.3f", fungibleEnergyCapacity))"
            , level: 80
        )

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
