import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    static let dispatchQueue = DispatchQueue(
        label: "ak.funge.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .userInitiated)
    )

    override func launch() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.debugColor(st, .yellow, .yellow)
        checkSpawnability { self.fungeRoute($0, $1) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        if !isAlive  {
            precondition(st.name == st.sprite.name)
            Log.L.write("isAlive == false, stepper(\(six(st.name))), stepper(\(six(st.sprite.name)))", level: 66)
            dp.apoptosize(); return }
        if !canSpawn { dp.plot(); return }

        dp.spawn()
    }
}

extension Funge {
    typealias OnComplete2p = (Bool, Bool) -> Void

    func checkSpawnability(_ onComplete: @escaping OnComplete2p) {

        func partA() { Clock.shared.getWorldClock { partB($0) } }

        func partB(_ worldClock: Int) {
            Funge.dispatchQueue.async {
                let (isAlive, canSpawn) = self.checkSpawnability(time: worldClock)
                onComplete(isAlive, canSpawn)
            }
        }

        partA()
    }

    func checkSpawnability(time: Int) -> (Bool, Bool) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }

        let age = st.getAge(time)

        let isAlive = st.metabolism.fungeProper(age: age, stillCounter: ch.stillCounter)
        let canSpawn = st.canSpawn()

        return (isAlive, canSpawn)
    }
}

extension Metabolism {
    func fungeProper(age: Int, stillCounter: CGFloat) -> Bool {
        let fudgeMassFactor: CGFloat = 10
        let joulesNeeded = fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let gracePeriodFactor: CGFloat = (age < 5 ? 0 : 1)
        let oxygenCost: CGFloat = 0.005 * gracePeriodFactor
        let ratchet: CGFloat = 1.0 //CGFloat(1 + Int(stillCounter * 100) / 5)
        let stillnessCost: CGFloat = (pow(1.01, stillCounter) - 1) * gracePeriodFactor * ratchet

        oxygenLevel -= oxygenCost + stillnessCost

        if stillnessCost > 0 {
            Log.L.write(
                "\nfungeProper:" +
                " mass    \(String(format: "%-2.6f", mass))," +
                " w/d     \(String(format: "%-2.6f", joulesNeeded))" +
                " still   \(String(format: "%03f", stillCounter))" +
                " cost    \(String(format: "%-2.6f", stillnessCost))" +
                " O2      \(String(format: "%-3.2f%%", oxygenLevel * 100))" +
                " cost    \(String(format: "%-2.6f", oxygenCost))" +
                " energy  \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
                " level   \(String(format: "%-2.6f", fungibleEnergyContent))" +
                " cap     \(String(format: "%-2.6f", fungibleEnergyCapacity))"
                , level: 66
            )
        }

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
