import CoreGraphics

enum OozeMedium: String { case force, gas, meat, pluripotentia, vitamins, work }

protocol Reportable {
    var level: CGFloat { get }
    var mass: CGFloat { get }
}

class OozeStorage: Reportable {
    internal init(
        capacity: CGFloat, density: CGFloat,
        medium: OozeMedium, overflowFullness: CGFloat? = nil,
        underflowFullness: CGFloat? = nil
    ) {
        self.capacity = capacity
        self.density = density
        self.medium = medium
        self.overflowFullness = overflowFullness
        self.underflowFullness = underflowFullness
    }

    let capacity:          CGFloat      // unspecified units
    let density:           CGFloat      // kg/unit
    var level:             CGFloat = 0  // same units as capacity
    let medium:            OozeMedium
    let overflowFullness:  CGFloat?
    let underflowFullness: CGFloat?

    var availableCapacity: CGFloat { capacity - level }
    var isOverflowing:     Bool    { fullness > (overflowFullness ?? 1) }
    var isUnderflowing:    Bool    { fullness < (underflowFullness ?? 0) }

    var fullness:  CGFloat { level / capacity }
    var isEmpty:   Bool    { level <= 0 }
    var isFull:    Bool    { level >= capacity }
    var isNominal: Bool    { !isEmpty && !isFull }
    var mass:      CGFloat { level * density }

    func deposit(_ quantity: CGFloat) {
        level = min((level + quantity), capacity)
    }

    @discardableResult
    func withdraw(_ quantity: CGFloat?) -> CGFloat {
        if let q = quantity {
            let net = min(level, q)
            level -= net
            return net
        } else {
            defer { level = 0 }
            return level
        }
    }

    @discardableResult
    func withdrawFromSurplus(max quantity: CGFloat) -> CGFloat {
        if (overflowFullness == nil) || !isOverflowing { return 0 }
        let net = min(quantity, (1 - overflowFullness!) * capacity)
        Debug.log(level: 175) { "withdrawFromSurplus(\(quantity)) -> net \(net)" }
        return withdraw(net)
    }
}

class VitaminStorage: OozeStorage {
    // Vitamin storage is already in kg, no conversion needed
    override var mass: CGFloat { return super.level }

    init() {
        super.init(
            capacity: EnergyBudget.VitaminStore.capacityKg,
            density: 1,
            medium: .vitamins,
            overflowFullness: 1,
            underflowFullness: 0
        )
    }
}

enum DeployableType: Int, CaseIterable { case bone, leather, poison }

class Deployable: Reportable {
    private let rawMaterial: OozeStorage
    let type: DeployableType
    private let vitamins: OozeStorage

    var level: CGFloat { fatalError() }
    var mass: CGFloat { rawMaterial.mass + vitamins.mass }

    internal init(type: DeployableType) {
        self.type = type

        self.rawMaterial = OozeStorage(
            capacity: EnergyBudget.Accessory.capacityVolts,
            density: EnergyBudget.Accessory.densityKgPerVcap,
            medium: .force, // (electromotive force, that is)
            overflowFullness: 1,
            underflowFullness: 0
        )

        self.vitamins = VitaminStorage()
    }

    func depositRawMaterial(_ quantity: CGFloat) { rawMaterial.deposit(quantity) }
    func depositVitamins(_ quantity: CGFloat) { vitamins.deposit(quantity) }
    func withdrawRawMaterial(_ quantity: CGFloat) -> CGFloat { return rawMaterial.withdraw(quantity) }
    func withdrawVitamins(_ quantity: CGFloat) -> CGFloat { return vitamins.withdraw(quantity) }
}

class Lungs: OozeStorage {
    override var mass: CGFloat { super.level * EnergyBudget.Lungs.densityKgPerCC }

    internal init() {
        super.init(
            capacity: EnergyBudget.Lungs.capacityCCs,
            density: EnergyBudget.Lungs.densityKgPerCC,
            medium: .gas,
            overflowFullness: 1,
            underflowFullness: 0
        )
    }

    func combust(_ cJoulesOfReactant: CGFloat) {
        let o2 = cJoulesOfReactant * EnergyBudget.Lungs.combustionCCsPerJoule
        let netO2 = super.withdraw(o2)
        if netO2 < o2 {
            Debug.log(level: 174) { "Out of oxygen; \(netO2) < \(o2)" }
        }
    }

    func inhale(_ ccsO2: CGFloat) { super.deposit(ccsO2) }
}

class ReadyEnergy: OozeStorage {
    internal init() {
        super.init(
            capacity: EnergyBudget.Ready.capacityJoules,
            density: EnergyBudget.Ready.densityKgPerJoule,
            medium: .work,
            overflowFullness: EnergyBudget.Ready.overflowFullness,
            underflowFullness: EnergyBudget.Ready.underflowFullness
        )
    }
}

class Stomach: OozeStorage {
    internal init() {
        super.init(
            capacity: EnergyBudget.Stomach.capacityKg,
            density: EnergyBudget.Stomach.densityKgPerJoule,
            medium: .meat,
            overflowFullness: 1,
            underflowFullness: 0
        )
    }
}
