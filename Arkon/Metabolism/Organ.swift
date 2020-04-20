import CoreGraphics

class Organ {
    internal init(
        capacity: CGFloat, energyDensity: CGFloat, transferRate: CGFloat
    ) {
        self.capacity = capacity
        self.energyDensity = energyDensity
        self.transferRate = transferRate
    }

    var fullness:  CGFloat { level / capacity }
    var isEmpty:   Bool    { level <= 0 }
    var isFull:    Bool    { level >= capacity }
    var isNominal: Bool    { !isEmpty && !isFull }
    var mass:      CGFloat { level / energyDensity }

    let capacity:      CGFloat    // in J
    let energyDensity: CGFloat    // in J/g
    var level =        CGFloat(0) // in J
    let transferRate:  CGFloat    // in J/sec

    func deposit(_ cJoules: CGFloat) {
        assert(cJoules > 0)
        level = min(level + cJoules, capacity)
    }

    @discardableResult
    func withdraw(
        _ cJoules: CGFloat, _ receiverRate: CGFloat? = nil, _ o2: CGFloat? = nil
    ) -> CGFloat {

        // When we eat, limit the transfer rate only to that of the ready
        // organ; we could make the muscles the receiver, but it seems
        // unnecessarily complex
        let rr = receiverRate ?? CGFloat.infinity

        // When we get oxygen from the lungs, we don't need more oxygen for
        // processing it like we need for the other organs
        let oo = o2 ?? CGFloat.infinity

        guard let net = [cJoules, level, oo, rr, transferRate].min()
            else { fatalError() }

        level -= net
        return net

    }

    @discardableResult
    func withdrawMax(receiverRate: CGFloat?, o2: CGFloat) -> CGFloat {
        withdraw(capacity, receiverRate, o2)
    }
}

enum AccessoryType: Int, CaseIterable { case bone, leather, poison }

class Accessory: Organ {
    let type: AccessoryType
    private(set) var vitaminLevel: CGFloat = 0

    internal init(
        capacity: CGFloat, energyDensity: CGFloat, transferRate: CGFloat,
        type: AccessoryType
    ) {
        self.type = type

        super.init(
            capacity: capacity, energyDensity: energyDensity, transferRate: transferRate
        )
    }

    func depositVitamin(from stomach: Stomach) {
        let net = stomach.withdrawVitamin(type)
        vitaminLevel = min(capacity, vitaminLevel + net)
    }

    func withdrawVitamin(_ cVitaminoids: CGFloat, o2: CGFloat) -> CGFloat {
        let netVitaminoids = min(vitaminLevel, (cVitaminoids * capacity / 10))
        vitaminLevel -= netVitaminoids

        return withdraw(netVitaminoids, nil, o2)
    }
}

class Oxygen: Organ {
    // This is an attempt to make the code easier to read elsewhere. It's the
    // amount of energy that can be created when combusting. With a reactivity
    // level of 1, I can combust 1 joule from the energy reserves
    override var level: CGFloat {
        set(L) { super.level = L * EnergyBudget.o2costPerJoule }
        get    { super.level / EnergyBudget.o2costPerJoule }
    }

    // Of course, the above complicates matters, because it might make us
    // seem a lot heavier than we really are, because the mass is calculated
    // from the resource level. Make sure to use the right one
    override var mass: CGFloat { super.level * EnergyBudget.o2costPerJoule }

    func combust(_ cJoulesOfReactant: CGFloat) {
        let o2 = cJoulesOfReactant * EnergyBudget.o2costPerJoule
        super.withdraw(o2)
    }

    func inhale(_ cJoulesOfO2: CGFloat) { super.deposit(cJoulesOfO2) }
}

class ReadyEnergy: Organ {
    internal init(
        capacity: CGFloat, energyDensity: CGFloat, transferRate: CGFloat,
        overflowFullness: CGFloat
    ) {
        self.overflowFullness = overflowFullness

        super.init(
            capacity: capacity, energyDensity: energyDensity, transferRate: transferRate
        )
    }

    override var isNominal: Bool { super.isNominal && !isOverflowing }

    var isOverflowing: Bool { fullness > overflowFullness }

    let overflowFullness: CGFloat   // in % of capacity
}

class Stomach: Organ {
    var vitaminLevel = [CGFloat](repeating: 0, count: AccessoryType.allCases.count)

    // Note that the 'capacity' here is actually the energy capacity of the
    // organ, not the vitaminoid capacity of the stomach's vitamin pouch.
    // Because laziness
    func depositVitamin(_ cVitaminoids: CGFloat, type: AccessoryType) {
        vitaminLevel[type.rawValue] =
            min(vitaminLevel[type.rawValue] + cVitaminoids, capacity)
    }

    func withdrawVitamin(_ type: AccessoryType) -> CGFloat {
        defer { vitaminLevel[type.rawValue] = 0 }
        return vitaminLevel[type.rawValue]
    }
}
