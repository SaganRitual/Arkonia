import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    static let dispatchQueue = DispatchQueue(
        label: "ak.funge.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    override func launch() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 95) { "Funge \(six(st.name))" }
        Debug.debugColor(st, .yellow, .blue)
        guard let ek = ch.engagerKey as? HotKey else { fatalError() }
        WorkItems.checkSpawnability(st) { self.fungeRoute($0, $1, ek) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool, _ hotKey: HotKey) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }

        Debug.log(level: 104) { "fungeRoute for \(six(st.name)) at \(st.gridCell.gridPosition) isAlive \(isAlive) canSpawn \(canSpawn)" }
        if !isAlive || st.gridCell.isInDangerZone {
            hotKey.releaseLock()
            dp.apoptosize()
            return
        }

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
        Census.dispatchQueue.async {
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
                age: age, co2Counter: stepper.dispatch.scratch.co2Counter
            )

            let canSpawn = stepper.canSpawn()

            onComplete(isAlive, canSpawn)
        }
    }
}

extension Metabolism {
    static var showHeader = true
    func fungeProper(age: Int, co2Counter: CGFloat) -> Bool {
        let joulesNeeded = Arkonia.fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: CGFloat = Arkonia.oxygenCostPerTick
        let co2Cost: CGFloat = pow(Arkonia.co2BaseCost, co2Counter)

        Debug.log(level: 96) { "O2 cost \(oxygenCost), CO2 cost \(co2Cost)" }

        oxygenLevel -= oxygenCost
        co2Level += co2Cost

        Debug.log(level: 96) { "O2 level \(oxygenLevel), CO2 level \(co2Level)" }

        return fungibleEnergyFullness > 0 && oxygenLevel > 0 && co2Level < Arkonia.co2MaxLevel
    }
}
