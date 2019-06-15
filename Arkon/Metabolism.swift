//swiftlint:disable file_length
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
        print(
            "[Deposit",
            String(format: "% 6.2f ", stomach.level),
            String(format: "% 6.2f ", readyEnergyReserves.level),
            String(format: "% 6.2f ", fatReserves.level),
            String(format: "% 6.2f ", spawnReserves.level),
            String(format: "% 6.2f ", energyContent),
            String(format: "(% 6.2f)", cJoules)
        )
        stomach.deposit(cJoules)
        print(
            "Deposit",
            String(format: "% 6.2f ", stomach.level),
            String(format: "% 6.2f ", readyEnergyReserves.level),
            String(format: "% 6.2f ", fatReserves.level),
            String(format: "% 6.2f ", spawnReserves.level),
            String(format: "% 6.2f ", energyContent),
            String(format: "(% 6.2f)\n]", cJoules)
        )
    }

    @discardableResult
    func expendEnergy(_ packet: EnergyPacketProtocol) -> CGFloat {
        defer {
            muscles = nil
            updatePhysicsBodyMass()
        }

        return muscles?.energyContent ?? 0
    }

    @discardableResult
    func loseEnergy(_ cJoules: CGFloat) -> EnergyPacketProtocol {
        let preMass = physicsBody.mass
        let preEnergy = energyContent
        let retrieved = readyEnergyReserves.withdraw(cJoules)

        updatePhysicsBodyMass()

        let lost = EnergyPacket(
            energyContent: preEnergy - energyContent, mass: preMass - physicsBody.mass
        )

        defer { updatePhysicsBodyMass() }

        return lost
    }

    func parasitize(_ victim: Metabolism) {
        let spareCapacity = 200 - stomach.level
        let attemptToTakeThisMuch = spareCapacity / 0.75
        let tookThisMuch = victim.loseEnergy(attemptToTakeThisMuch)
        let netEnergy = tookThisMuch.energyContent * 0.75

//        print("Absorbing \(netEnergy), current = \(energyContent), ready = \(readyEnergyReserves.level)")
        absorbEnergy(netEnergy)
    }

    func retrieveEnergy(_ cJoules: CGFloat) -> EnergyPacketProtocol {
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

    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    static func parasiteTest() {
        let predatorObject = ObjectWithMass()
        let predatorMetabolism = Metabolism(predatorObject)
        let preyObject = ObjectWithMass()
        let preyMetabolism = Metabolism(preyObject)

        checkLevels(
            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 2000, fat: 500, spawn: 0
        )

        checkLevels(
            metabolism: preyMetabolism, stomach: 0, readyEnergy: 2000, fat: 500, spawn: 0
        )

        // Fatten up the prey before we start eating it
        for _ in 0..<8500 {
            preyMetabolism.absorbEnergy(1)
            tick(preyMetabolism, preyObject)
        }

        checkLevels(
            metabolism: preyMetabolism, stomach: 200, readyEnergy: 2400, fat: 3200, spawn: 3200
        )

        // To get integers from the conversions, we can get 4/3 of 180
        predatorMetabolism.absorbEnergy(24)
        tick(predatorMetabolism, predatorObject)

        checkLevels(
            metabolism: predatorMetabolism, stomach: 20, readyEnergy: 2000, fat: 504, spawn: 0
        )

        // Request 180mJ; requires 240mJ input to cover conversion loss
        predatorMetabolism.parasitize(preyMetabolism)
        tick(predatorMetabolism, predatorObject)

        checkLevels(
            metabolism: preyMetabolism, stomach: 200, readyEnergy: 2160, fat: 3200, spawn: 3200
        )

        checkLevels(
            metabolism: predatorMetabolism, stomach: 196, readyEnergy: 2000, fat: 508, spawn: 0
        )

        let muscles = predatorMetabolism.retrieveEnergy(20)
        predatorMetabolism.expendEnergy(muscles)
        tick(predatorMetabolism, predatorObject)

        checkLevels(
            metabolism: preyMetabolism, stomach: 200, readyEnergy: 2160, fat: 3200, spawn: 3200
        )

        checkLevels(
            metabolism: predatorMetabolism, stomach: 192, readyEnergy: 1984, fat: 508, spawn: 0
        )

        for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }

        checkLevels(
            metabolism: predatorMetabolism, stomach: 4, readyEnergy: 2000, fat: 680, spawn: 0
        )

        predatorMetabolism.loseEnergy(2000)

        checkLevels(
            metabolism: predatorMetabolism, stomach: 4, readyEnergy: 0, fat: 680, spawn: 0
        )

        for _ in (0..<74) { tick(predatorMetabolism, predatorObject) }

        checkLevels(
            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 596, fat: 88, spawn: 0
        )

        predatorMetabolism.loseEnergy(596)

        checkLevels(
            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 0, fat: 88, spawn: 0
        )

        for _ in (0..<11) { tick(predatorMetabolism, predatorObject) }
        predatorMetabolism.loseEnergy(88)

        checkLevels(
            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 0, fat: 0, spawn: 0
        )

        // To get integers from the conversions, we can get 4/3 of 180
        predatorMetabolism.absorbEnergy(20)

        // Request 180mJ; requires 240mJ input to cover conversion loss
        predatorMetabolism.parasitize(preyMetabolism)
        tick(predatorMetabolism, predatorObject)

        checkLevels(
            metabolism: preyMetabolism, stomach: 200, readyEnergy: 1920, fat: 3200, spawn: 3200
        )

        checkLevels(
            metabolism: predatorMetabolism, stomach: 196, readyEnergy: 4, fat: 0, spawn: 0
        )

        for _ in (0..<48) { tick(predatorMetabolism, predatorObject) }

        checkLevels(
            metabolism: predatorMetabolism, stomach: 4, readyEnergy: 196, fat: 0, spawn: 0
        )

        for _ in 0..<7 {
            // To get integers from the conversions, we can get 4/3 of 180
            predatorMetabolism.absorbEnergy(16)

            // Request 180mJ; requires 240mJ input to cover conversion loss
            predatorMetabolism.parasitize(preyMetabolism)
            tick(predatorMetabolism, predatorObject)

            for _ in (0..<48) { tick(predatorMetabolism, predatorObject) }
        }

        checkLevels(
            metabolism: preyMetabolism, stomach: 200, readyEnergy: 240, fat: 3200, spawn: 3200
        )

        checkLevels(
            metabolism: predatorMetabolism, stomach: 4, readyEnergy: 1568, fat: 0, spawn: 0
        )

        for _ in (0..<49) { tick(preyMetabolism, preyObject) }

        checkLevels(
            metabolism: preyMetabolism, stomach: 4, readyEnergy: 676, fat: 2960, spawn: 3200
        )

        for _ in (0..<1) { tick(predatorMetabolism, predatorObject) }

        checkLevels(
            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 1572, fat: 0, spawn: 0
        )

        for _ in (0..<1) { tick(preyMetabolism, preyObject) }

        for _ in 0..<3 {
            // To get integers from the conversions, we can get 4/3 of 180
            predatorMetabolism.absorbEnergy(20)
            // Request 180mJ; requires 240mJ input to cover conversion loss
            predatorMetabolism.parasitize(preyMetabolism)
            tick(predatorMetabolism, predatorObject)

            for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }
        }

        for _ in (0..<74) { tick(preyMetabolism, preyObject) }

        checkLevels(
            metabolism: preyMetabolism, stomach: 0, readyEnergy: 592, fat: 2368, spawn: 3200
        )

        for _ in 0..<3 {
            // To get integers from the conversions, we can get 4/3 of 180
            predatorMetabolism.absorbEnergy(20)
            // Request 180mJ; requires 240mJ input to cover conversion loss
            predatorMetabolism.parasitize(preyMetabolism)
            tick(predatorMetabolism, predatorObject)

            for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }
        }

        for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }
        for _ in (0..<100) { tick(preyMetabolism, preyObject) }

        checkLevels(
            metabolism: preyMetabolism, stomach: 0, readyEnergy: 600, fat: 1768, spawn: 3200
        )

//        checkLevels(
//            metabolism: predatorMetabolism, stomach: 0, readyEnergy: 2000, fat: 646, spawn: 0
//        )

        for _ in 0..<5 {
            for _ in 0..<2 {
                // To get integers from the conversions, we can get 4/3 of 180
                predatorMetabolism.absorbEnergy(20)
                // Request 180mJ; requires 240mJ input to cover conversion loss
                predatorMetabolism.parasitize(preyMetabolism)
                tick(predatorMetabolism, predatorObject)

                for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }
            }

            for _ in (0..<47) { tick(predatorMetabolism, predatorObject) }
            for _ in (0..<67) { tick(preyMetabolism, preyObject) }
        }

        predatorMetabolism.parasitize(preyMetabolism)
        tick(predatorMetabolism, predatorObject)

        checkLevels(
            metabolism: preyMetabolism, stomach: 0, readyEnergy: 0, fat: 0, spawn: 3200
        )

        for _ in (0..<3) { tick(predatorMetabolism, predatorObject) }

        precondition(predatorMetabolism.stomach.level == 0)
        precondition(predatorMetabolism.readyEnergyReserves.level == 2000)
        precondition(predatorMetabolism.fatReserves.level > 2397 && predatorMetabolism.fatReserves.level < 2398)
        precondition(predatorMetabolism.spawnReserves.level == 224)

        print("parasite test ok")
    }
    //swiftlint:enable function_body_length
    //swiftlint:enable cyclomatic_complexity

    static func rawEnergyTest() {
        let massiveObject = ObjectWithMass()
        let metabolism = Metabolism(massiveObject)

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 2000, fat: 500, spawn: 0
        )

        for _ in 0..<1500 {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 2000, fat: 2000, spawn: 0
        )

        for _ in 0..<40 {
            let muscles = metabolism.retrieveEnergy(50)
            metabolism.expendEnergy(muscles)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 96, fat: 1904, spawn: 0
        )

        for _ in 0..<2000 {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 2000, fat: 2000, spawn: 0
        )

        for _ in 0..<10 {
            let muscles = metabolism.retrieveEnergy(50)
            metabolism.expendEnergy(muscles)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 1500, fat: 2000, spawn: 0
        )

        for _ in 0..<(4900 - 1) {
            metabolism.absorbEnergy(1)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 2000, fat: 3199, spawn: 3200
        )

        for _ in 0..<427 {
            let muscles = metabolism.retrieveEnergy(50)
            metabolism.expendEnergy(muscles)
            tick(metabolism, massiveObject)
        }

        checkLevels(
            metabolism: metabolism, stomach: 0, readyEnergy: 8, fat: 7, spawn: 3200
        )

        print("Metabolism raw energy test ok")
    }

    static func tick(_ metabolism: Metabolism, _ massiveObject: Massive) {
        metabolism.tick()
//
//        [
//            metabolism.bone, metabolism.stomach, metabolism.readyEnergyReserves,
//            metabolism.fatReserves, metabolism.spawnReserves
//        ].forEach {
//                print("\($0.level), ", terminator: "")
//        }
//        print("mass = \(massiveObject.mass)")
    }
}
//swiftlint:enable file_length
