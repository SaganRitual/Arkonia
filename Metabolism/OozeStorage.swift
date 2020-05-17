import Foundation

class OozeStorage: Protoplasm, StorageProtocol {
    internal init(_ organID: OrganID) {
        self.E = EnergyBudget.makeEnergyBudgetForBasicStore(organID)

        self.maintCostWorkPerCap = self.E.maintCostWorkPerCap
        self.maintCostOozePerCap = self.E.maintCostOozePerCap
        self.mfgCostWorkPerCap = self.E.mfgCostWorkPerCap
        self.mfgCostOozePerCap = self.E.mfgCostOozePerCap

        (capacity, organMass) = OozeStorage.init_(self.E)
    }

    internal init(_ organID: OrganID, _ chamberID: ChamberID) {
        self.E = EnergyBudget.makeEnergyBudgetForChamberedStore(organID, chamberID)

        self.maintCostWorkPerCap = self.E.maintCostWorkPerCap
        self.maintCostOozePerCap = self.E.maintCostOozePerCap
        self.mfgCostWorkPerCap = self.E.mfgCostWorkPerCap
        self.mfgCostOozePerCap = self.E.mfgCostOozePerCap

        (capacity, organMass) = OozeStorage.init_(self.E)
    }

    static func init_(_ E: EnergyBudget) -> (CGFloat, CGFloat) {
        let capacity = E.capacity
        let organMass = E.capacity * E.organDensity * RealWorldConversions.arkoniaKgPerRealKg

        return (capacity, organMass)
    }

    let E: EnergyBudget

    let capacity:  CGFloat
    let organMass: CGFloat

    let maintCostOozePerCap: CGFloat
    let maintCostWorkPerCap: CGFloat
    let mfgCostOozePerCap:   CGFloat
    let mfgCostWorkPerCap:   CGFloat

    var availableCapacity: CGFloat { E.capacity - level }
    var isOverflowing:     Bool    { fullness > (E.overflowFullness ?? 1) }
    var isUnderflowing:    Bool    { fullness < (E.underflowFullness ?? 0) }

    var contentMass: CGFloat { level * E.contentDensity * RealWorldConversions.arkoniaKgPerRealKg }
    var fullness:    CGFloat { level / E.capacity }
    var isEmpty:     Bool    { level <= 0 }
    var isFull:      Bool    { level >= E.capacity }
    var isNominal:   Bool    { !isEmpty && !isUnderflowing && !isOverflowing && !isFull }
    var mass:        CGFloat { organMass + contentMass }

    var level: CGFloat = 0

    @discardableResult
    func withdrawFromSurplus(max quantity: CGFloat) -> CGFloat {
        if !isOverflowing { return 0 }
        let net = min(quantity, (1 - E.overflowFullness!) * E.capacity)
        Debug.log(level: 179) { "OozeStorage.withdrawFromSurplus(\(quantity)) -> \(net)" }
        return withdraw(net)
    }
}
