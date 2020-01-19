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
        Debug.log("Funge \(six(st.name))", level: 95)
        Debug.debugColor(st, .yellow, .yellow)
        WorkItems.checkSpawnability(st) { self.fungeRoute($0, $1) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }

        if !isAlive || st.gridCell.isInDangerZone { Debug.log("FungeRoute1 \(six(st.name))", level: 95); dp.apoptosize(); return }

        st.sprite.setScale(Arkonia.arkonScaleFactor * (1 + st.metabolism.spawnEnergyFullness) / Arkonia.zoomFactor)

        if !canSpawn { Debug.log("FungeRoute2 \(six(st.name))", level: 95); dp.plot(); return }

        Debug.log("FungeRoute3 \(six(st.name))", level: 95)
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

        Debug.log("O2 cost \(oxygenCost), CO2 cost \(co2Cost)", level: 96)

        oxygenLevel -= oxygenCost
        co2Level += co2Cost

        Debug.log("O2 level \(oxygenLevel), CO2 level \(co2Level)", level: 96)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0 && co2Level < Arkonia.co2MaxLevel
    }
}
