import SpriteKit

class Metabolism {
    let allReserves: [EnergyReserve]
    let fungibleReserves: [EnergyReserve]
    let reUnderflowThreshold: CGFloat

    var co2Level: CGFloat = 0
    var oxygenLevel: CGFloat = 1.0

    var bone = EnergyReserve(.bone)
    var fatReserves = EnergyReserve(.fatReserves)
    var readyEnergyReserves = EnergyReserve(.readyEnergyReserves)
    var spawnReserves = EnergyReserve(.spawnReserves)
    var stomach = EnergyReserve(.stomach)

    var energyCapacity: CGFloat {
        return allReserves.reduce(0.0) { subtotal, reserves in
            subtotal + reserves.capacity
        }
    }

    var fungibleEnergyCapacity: CGFloat {
        return fungibleReserves.reduce(0.0) { subtotal, reserves in
            subtotal + reserves.capacity
        }
    }

    var energyContent: CGFloat {
        return allReserves.reduce(0.0) { subtotal, reserves in
            return subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var fungibleEnergyContent: CGFloat {
        return fungibleReserves.reduce(0.0) { subtotal, reserves in
            return subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var energyFullness: CGFloat { return energyContent / energyCapacity }

    var fungibleEnergyFullness: CGFloat { return fungibleEnergyContent / fungibleEnergyCapacity }

    var hunger: CGFloat { return 1 - energyFullness }

    var spawnEnergyFullness: CGFloat {
        return spawnReserves.level / spawnReserves.capacity }

    var mass: CGFloat {
        let m: CGFloat = self.allReserves.reduce(0.0) {
            subtotal, reserve in
            Debug.log(level: 95) { "reserve \(reserve.name) level = \(reserve.level), reserve mass = \(reserve.mass)" }
            return subtotal + reserve.mass
        }

        Debug.log(level: 95) { "mass: \(m)" }

        return m
    }

    var massCapacity: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + (reserves.capacity / reserves.energyDensity)
        }
    }

    init() {
        self.allReserves = [bone, stomach, readyEnergyReserves, fatReserves, spawnReserves]
        self.fungibleReserves = [readyEnergyReserves, fatReserves]

        // Overflow is 5/6, make underflow 1/4, see how it goes
        self.reUnderflowThreshold = 1.0 / 4.0 * readyEnergyReserves.capacity

        Debug.log(level: 84) {
            "Metabolism():" +
            " mass \(String(format: "%-2.6f", mass))," +
            " O2 \(String(format: "%-3.2f%%", oxygenLevel * 100))" +
            " CO2 \(String(format: "%-3.2f%%", co2Level * 100))" +
            " energy \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
            " level \(String(format: "%-2.6f", fungibleEnergyContent))" +
            " cap \(String(format: "%-2.6f", fungibleEnergyCapacity))\n"
        }
    }

    static var absorbEnergyHeader = false
    func absorbEnergy(_ cJoules: CGFloat) {
        respire()

//        Debug.log(
//            "[Deposit " +
//            String(format: "% 6.2f ", stomach.level) +
//            String(format: "% 6.2f ", readyEnergyReserves.level) +
//            String(format: "% 6.2f ", fatReserves.level) +
//            String(format: "% 6.2f ", spawnReserves.level) +
//            String(format: "% 6.2f ", energyContent) +
//            String(format: "(% 6.2f)", cJoules),
//            level: 14
//        )

        stomach.deposit(cJoules)
        Debug.log(level: 96) {
            "Deposit to stomach"
            + String(format: "% 6.6f joules", cJoules)
            + String(format: "% 6.6f%% full", 100.0 * stomach.level / stomach.capacity)
            + String(format: ", O2 % 6.6f%%", oxygenLevel)
            + String(format: ", CO2 % 6.6f%%", co2Level)
        }

        if false && !Metabolism.absorbEnergyHeader {
            Debug.log(level: 88) { "Deposit    cJoules   fungible    stomach      ready        fat      spawn    content" }
            Metabolism.absorbEnergyHeader = true
        }

        Debug.log(level: 95) {
            "Deposit " +
            String(format: "% 10.2f ", cJoules) +
            String(format: "% 10.2f ", fungibleEnergyFullness) +
            String(format: "% 10.2f ", stomach.level) +
            String(format: "% 10.2f ", readyEnergyReserves.level) +
            String(format: "% 10.2f ", fatReserves.level) +
            String(format: "% 10.2f ", spawnReserves.level) +
            String(format: "% 10.2f ", energyContent)
        }
    }

    func respire(_ inhale: CGFloat = 1.0, _ exhale: CGFloat = Arkonia.co2MaxLevel) {
        oxygenLevel = constrain(inhale + oxygenLevel, lo: 0.0, hi: 1)
        co2Level = max(co2Level - exhale, 0.0)

        Debug.log(level: 96) { "respire; o2: \(oxygenLevel), co2 \(co2Level)" }
    }

    @discardableResult
    func withdrawFromReady(_ cJoules: CGFloat) -> CGFloat {
        return readyEnergyReserves.withdraw(cJoules)
    }

    @discardableResult
    func withdrawFromSpawn(_ cJoules: CGFloat) -> CGFloat {
        return spawnReserves.withdraw(cJoules)
    }
}
