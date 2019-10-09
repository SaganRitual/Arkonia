import SpriteKit

enum EnergyReserveType: CaseIterable {
    case bone, fatReserves, readyEnergyReserves, spawnReserves, stomach
}

class EnergyPacket: EnergyPacketProtocol {
    let energyContent: CGFloat  // in mJ
    let mass: CGFloat           // in g

    init(energyContent: CGFloat, mass: CGFloat) {
        self.energyContent = energyContent
        self.mass = mass
    }
}

class EnergyReserve {
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
    var level: CGFloat                          // in mJ
    let overflowThreshold: CGFloat              // in mJ

    init(_ type: EnergyReserveType) {
        self.energyReserveType = type

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
    }

    func deposit(_ cJoules: CGFloat) {
        if cJoules <= 0 { return }  // Energy level can go slightly neg, rounding?

        level = min(level + cJoules, capacity)
    }

    @discardableResult
    func withdraw(_ cJoules: CGFloat) -> CGFloat {
        if cJoules == 0 { return 0 }
        precondition(cJoules > 0)

        let net = min(level, cJoules)
        level -= net
        return net
    }
}

class Metabolism: EnergySourceProtocol, MetabolismProtocol {
    let allReserves: [EnergyReserve]
    weak var core: Arkon?
    let fungibleReserves: [EnergyReserve]
    var mass: CGFloat = 0
    var oxygenLevel: CGFloat = 1.0

    var bone = EnergyReserve(.bone)
    var fatReserves = EnergyReserve(.fatReserves)
    var readyEnergyReserves = EnergyReserve(.readyEnergyReserves)
    var spawnReserves = EnergyReserve(.spawnReserves)
    var stomach = EnergyReserve(.stomach)

    let reUnderflowThreshold: CGFloat

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
            subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var fungibleEnergyContent: CGFloat {
        return fungibleReserves.reduce(0) { subtotal, reserves in
            subtotal + reserves.level
        }// + (muscles?.energyContent ?? 0)
    }

    var energyFullness: CGFloat { return energyContent / energyCapacity }

    var fungibleEnergyFullness: CGFloat { return fungibleEnergyContent / fungibleEnergyCapacity }

    var spawnEnergyFullness: CGFloat { return spawnReserves.level / spawnReserves.capacity }

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

    func parasitize(_ victim: Metabolism) {
        let spareCapacity = stomach.capacity - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.withdrawFromReady(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch * 0.75

//        print("Absorbing \(netEnergy), current = \(energyContent), ready = \(readyEnergyReserves.level)")
        absorbEnergy(netEnergy)
        inhale()
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

    func tick() {
        let internalTransferRate: CGFloat = CGFloat(Double.infinity)

        defer { updatePhysicsBodyMass() }

        var export = !stomach.isEmpty && !readyEnergyReserves.isFull

        if export {
            let transfer = stomach.withdraw(25 * readyEnergyReserves.energyDensity)
            readyEnergyReserves.deposit(transfer)
        }

        export = readyEnergyReserves.isAmple && !fatReserves.isFull

        if export {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, internalTransferRate * fatReserves.energyDensity)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
        }

        let `import` = readyEnergyReserves.level < reUnderflowThreshold

        if `import` {
            let refill = fatReserves.withdraw(internalTransferRate * fatReserves.energyDensity)
            readyEnergyReserves.deposit(refill)
        }

        export = fatReserves.isAmple && !spawnReserves.isFull

        if export {
            let transfer = fatReserves.withdraw(internalTransferRate * spawnReserves.energyDensity)
            spawnReserves.deposit(transfer)
        }
    }

    func updatePhysicsBodyMass() {
        mass = CGFloat(allReserves.reduce(0) {
            subtotal, reserves in subtotal + (reserves.level / reserves.energyDensity)
        }) / 1000 //+ (muscles?.mass ?? 0)

//        print("pass", physicsBody.mass, (muscles?.mass ?? 0))
    }
}

extension Metabolism {
    class ObjectWithMass: Massive {
        var mass: CGFloat = 0
    }

    static func checkLevels(
        metabolism: Metabolism, stomach: CGFloat, readyEnergy: CGFloat, fat: CGFloat, spawn: CGFloat
    ) {
        precondition(metabolism.stomach.level == stomach)
        precondition(metabolism.readyEnergyReserves.level == readyEnergy)
        precondition(metabolism.fatReserves.level == fat)
        precondition(metabolism.spawnReserves.level == spawn)
    }

    static func tick(_ metabolism: Metabolism, _ massiveObject: Massive) {
        metabolism.tick()
    }
}
