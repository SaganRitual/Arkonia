import SpriteKit

enum EnergyReserveType: CaseIterable {
    case bone, fatReserves, readyEnergyReserves, spawnReserves, stomach
}

struct EnergyPacket: EnergyPacketProtocol {
    let energyContent: CGFloat  // in mJ
    let mass: CGFloat           // in g

    init(energyContent: CGFloat, mass: CGFloat) {
        self.energyContent = energyContent
        self.mass = mass
    }
}

struct EnergyReserve {
    static let startingLevelBone: CGFloat = 100
    static let startingLevelFat: CGFloat = 500
    static let startingLevelReadyEnergy: CGFloat = 2000

    static let startingEnergyLevel = (
        startingLevelBone + startingLevelFat + startingLevelReadyEnergy
    )

    var isAmple: Bool { return level >= overflowThreshold }
    var isEmpty: Bool { return level <= 0 }
    var isFull: Bool { return level >= capacity }
    var mass: CGFloat { return level / energyDensity }

    let capacity: CGFloat                       // in mJ
    let energyDensity: CGFloat                  // in J/g
    let energyReserveType: EnergyReserveType
    let overflowThreshold: CGFloat              // in mJ

    var level: CGFloat = 0                      // in mJ

    init(_ type: EnergyReserveType) {
        self.energyReserveType = type

        let level: CGFloat

        switch type {
        case .bone:
            capacity = 100
            energyDensity = 1
            level = EnergyReserve.startingLevelBone
            overflowThreshold = CGFloat.infinity

        case .fatReserves:
            capacity = 3200
            energyDensity = 8
            level = EnergyReserve.startingLevelFat
            overflowThreshold = 2400

        case .readyEnergyReserves:
            capacity = 2400
            energyDensity = 4
            level = EnergyReserve.startingLevelReadyEnergy
            overflowThreshold = 2000

        case .spawnReserves:
            capacity = 3200
            energyDensity = 16
            level = 0
            overflowThreshold = CGFloat.infinity

        case .stomach:
            capacity = 800
            energyDensity = 2
            level = 0
            overflowThreshold = 0
        }

        self.level = level
    }

    mutating func deposit(_ cJoules: CGFloat) {
        if cJoules <= 0 { return }  // Energy level can go slightly neg, rounding?

        level = min(level + cJoules, capacity)
    }

    @discardableResult
    mutating func withdraw(_ cJoules: CGFloat) -> CGFloat {
        if cJoules == 0 { return 0 }
        precondition(cJoules > 0)

        let net = min(level, cJoules)
        level -= net
        return net
    }
}

class Metabolism {
    let allReserves: [EnergyReserve]
    weak var core: Arkon?
    let fungibleReserves: [EnergyReserve]
    let reUnderflowThreshold: CGFloat

    var mass: CGFloat = 0
    var oxygenLevel: CGFloat = 1.0

    var bone = EnergyReserve(.bone)
    var fatReserves = EnergyReserve(.fatReserves)
    var readyEnergyReserves = EnergyReserve(.readyEnergyReserves)
    var spawnReserves = EnergyReserve(.spawnReserves)
    var stomach = EnergyReserve(.stomach)

    var energyCapacity: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + reserves.capacity
        }
    }

    var fungibleEnergyCapacity: CGFloat {
        return fungibleReserves.reduce(0) { subtotal, reserves in
            subtotal + reserves.capacity
        }
    }

    var energyContent: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            return subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var fungibleEnergyContent: CGFloat {
        return fungibleReserves.reduce(0) { subtotal, reserves in
            return subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var energyFullness: CGFloat {
        return energyContent / energyCapacity }

    var fungibleEnergyFullness: CGFloat { return fungibleEnergyContent / fungibleEnergyCapacity }

    var spawnEnergyFullness: CGFloat {
        return spawnReserves.level / spawnReserves.capacity }

    var massCapacity: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + (reserves.capacity / reserves.energyDensity)
        }
    }

    init(core: Arkon) {
        self.core = core
        self.allReserves = [bone, stomach, readyEnergyReserves, fatReserves, spawnReserves]
        self.fungibleReserves = [readyEnergyReserves, fatReserves]

        // Overflow is 5/6, make underflow 1/4, see how it goes
        self.reUnderflowThreshold = 1.0 / 4.0 * readyEnergyReserves.capacity
    }

    func absorbEnergy(_ cJoules: CGFloat) {
        defer { updatePhysicsBodyMass() }

//        print(
//            "[Deposit",
//            String(format: "% 6.2f ", stomach.level),
//            String(format: "% 6.2f ", readyEnergyReserves.level),
//            String(format: "% 6.2f ", fatReserves.level),
//            String(format: "% 6.2f ", spawnReserves.level),
//            String(format: "% 6.2f ", energyContent),
//            String(format: "(% 6.2f)", cJoules)
//        )

        stomach.deposit(cJoules)

//        print(
//            " Deposit",
//            String(format: "% 6.2f ", stomach.level),
//            String(format: "% 6.2f ", readyEnergyReserves.level),
//            String(format: "% 6.2f ", fatReserves.level),
//            String(format: "% 6.2f ", spawnReserves.level),
//            String(format: "% 6.2f ", energyContent),
//            String(format: "(% 6.2f)\n]", cJoules)
//        )
    }

    func inhale() {
        oxygenLevel = constrain(1, lo: 0, hi: 1)

//        print("d", arkon.arkon.selectoid.fishNumber, arkon.arkon.metabolism.oxygenLevel)
    }

    @discardableResult
    func withdrawFromReady(_ cJoules: CGFloat) -> CGFloat {
        defer { updatePhysicsBodyMass() }
        return readyEnergyReserves.withdraw(cJoules)
    }

    @discardableResult
    func withdrawFromSpawn(_ cJoules: CGFloat) -> CGFloat {
        defer { updatePhysicsBodyMass() }
        return spawnReserves.withdraw(cJoules)
    }

    func updatePhysicsBodyMass() {
        self.mass = CGFloat(self.allReserves.reduce(0) { subtotal, reserves in
            return subtotal + Int((reserves.level / reserves.energyDensity))
        }) / 1000 //+ (muscles?.mass ?? 0)
    }
}
