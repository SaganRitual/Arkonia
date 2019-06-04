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
            level = 100
            overflowThreshold = CGFloat.infinity

        case .fatReserves:
            capacity = 3200
            energyDensity = 8
            level = 500
            overflowThreshold = 2400

        case .readyEnergyReserves:
            capacity = 2400
            energyDensity = 4
            level = 2000
            overflowThreshold = 2000

        case .spawnReserves:
            capacity = 3200
            energyDensity = 16
            level = 0
            overflowThreshold = CGFloat.infinity

        case .stomach:
            capacity = 200
            energyDensity = 2
            level = 0
            overflowThreshold = 0
        }
    }

    func deposit(_ cJoules: CGFloat) {
        if cJoules == 0 { return }
        precondition(cJoules > 0)

        level = min(level + cJoules, capacity)
    }

    func withdraw(_ cJoules: CGFloat) -> CGFloat {
        if cJoules == 0 { return 0 }
        precondition(cJoules > 0)

        let net = min(level, cJoules)
        level -= net
        return net
    }
}

class Metabolism: EnergySourceProtocol {
    var physicsBody: Massive

    let allReserves: [EnergyReserve]

    var bone = EnergyReserve(.bone)
    var fatReserves = EnergyReserve(.fatReserves)
    var muscles: EnergyPacket?
    var readyEnergyReserves = EnergyReserve(.readyEnergyReserves)
    var spawnReserves = EnergyReserve(.spawnReserves)
    var stomach = EnergyReserve(.stomach)

    let reUnderflowThreshold: CGFloat

    var energyCapacity: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + reserves.capacity
        }
    }

    var energyContent: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + reserves.level
        } + (muscles?.energyContent ?? 0)
    }

    var energyFullness: CGFloat { return energyContent / energyCapacity }

    var massCapacity: CGFloat {
        return allReserves.reduce(0) { subtotal, reserves in
            subtotal + (reserves.capacity / reserves.energyDensity)
        }
    }

    init(_ physicsBody: Massive) {
        self.physicsBody = physicsBody
        self.allReserves = [bone, stomach, readyEnergyReserves, fatReserves, spawnReserves]

        // Overflow is 5/6, make underflow 1/4, see how it goes
        self.reUnderflowThreshold = 1.0 / 4.0 * readyEnergyReserves.capacity
    }

    func absorbEnergy(_ cJoules: CGFloat) {
        defer { updatePhysicsBodyMass() }
        stomach.deposit(cJoules)
    }

    func expendEnergy(_ packet: EnergyPacket) -> CGFloat {
        defer {
            muscles = nil
            updatePhysicsBodyMass()
        }

        return muscles?.energyContent ?? 0
    }

    func retrieveEnergy(_ cJoules: CGFloat) -> EnergyPacket {
        let preMass = physicsBody.mass
        let preEnergy = energyContent
        let retrieved = readyEnergyReserves.withdraw(cJoules)

        updatePhysicsBodyMass()

        muscles = EnergyPacket(
            energyContent: preEnergy - energyContent, mass: preMass - physicsBody.mass
        )

        defer { updatePhysicsBodyMass() }
        return muscles!
    }

    func tick() {
        defer { updatePhysicsBodyMass() }

        var export = !stomach.isEmpty && !readyEnergyReserves.isFull

        if export {
            let transfer = stomach.withdraw(1 * readyEnergyReserves.energyDensity)
            readyEnergyReserves.deposit(transfer)
        }

        export = readyEnergyReserves.isAmple && !fatReserves.isFull

        if export {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, 1 * fatReserves.energyDensity)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
        }

        let `import` = readyEnergyReserves.level < reUnderflowThreshold

        if `import` {
            let refill = fatReserves.withdraw(1 * fatReserves.energyDensity)
            readyEnergyReserves.deposit(refill)
        }

        export = fatReserves.isAmple && !spawnReserves.isFull

        if export {
            let transfer = fatReserves.withdraw(1 * spawnReserves.energyDensity)
            spawnReserves.deposit(transfer)
        }
    }

    func updatePhysicsBodyMass() {
        physicsBody.mass = CGFloat(allReserves.reduce(0) {
            subtotal, reserves in subtotal + (reserves.level / reserves.energyDensity)
        }) / 1000 + (muscles?.mass ?? 0)

        print("pass", physicsBody.mass, (muscles?.mass ?? 0))
    }
}

extension Metabolism {
    class ObjectWithMass: Massive {
        var mass: CGFloat = 0
    }

    static func selfTest() {
        let massiveObject = ObjectWithMass()
        let metabolism = Metabolism(massiveObject)
        for _ in 0..<1500 {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        print("first wd")
        for _ in 0..<40 {
            let muscles = metabolism.retrieveEnergy(50)
            let net = metabolism.expendEnergy(muscles)
            print("net = \(net)")
            tick(metabolism, massiveObject)
        }

        for _ in 0..<2000 {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        print("second wd")
        for _ in 0..<10 {
            let muscles = metabolism.retrieveEnergy(50)
            let net = metabolism.expendEnergy(muscles)
            print("net = \(net)")
            tick(metabolism, massiveObject)
        }

        for _ in 0..<6000 {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        print("third wd")
        for _ in 0..<1000 {
            let muscles = metabolism.retrieveEnergy(50)
            let net = metabolism.expendEnergy(muscles)
            print("net = \(net)")
            tick(metabolism, massiveObject)
        }
    }

    static func tick(_ metabolism: Metabolism, _ massiveObject: Massive) {
        metabolism.tick()

        [
            metabolism.bone, metabolism.stomach, metabolism.readyEnergyReserves,
            metabolism.fatReserves, metabolism.spawnReserves
        ].forEach {
                print("\($0.level), ", terminator: "")
        }
        print("mass = \(massiveObject.mass)")
    }
}
