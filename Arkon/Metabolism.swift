import Accelerate
import SpriteKit

class Metabolism {
    let allReserves: [EnergyReserve]
    let fungibleReserves: [EnergyReserve]
    let reUnderflowThreshold: CGFloat

    var co2Level: CGFloat = 0
    var oxygenLevel: CGFloat = 1.0

    let capacities = HotReserve()
    let levels = HotReserve()

    var bone: EnergyReserve
    var fatReserves: EnergyReserve
    var readyEnergyReserves: EnergyReserve
    var spawnReserves: EnergyReserve
    var stomach: EnergyReserve

    var energyCapacity: CGFloat { capacities.sum(.all) }
    var fungibleEnergyCapacity: CGFloat { capacities.sum(.fungible) }

    var energyContent: CGFloat { levels.sum(.all) }
    var fungibleEnergyContent: CGFloat { levels.sum(.fungible) }

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
        bone = EnergyReserve(.bone, capacities, HotReserve.Reserve.bone.rawValue, levels)
        fatReserves = EnergyReserve(.fatReserves, capacities, HotReserve.Reserve.fat.rawValue, levels)
        readyEnergyReserves = EnergyReserve(.readyEnergyReserves, capacities, HotReserve.Reserve.ready.rawValue, levels)
        spawnReserves = EnergyReserve(.spawnReserves, capacities, HotReserve.Reserve.spawn.rawValue, levels)
        stomach = EnergyReserve(.stomach, capacities, HotReserve.Reserve.stomach.rawValue, levels)

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

    func absorbEnergy(_ cJoules: CGFloat) {
        respire()
        stomach.deposit(cJoules)
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
