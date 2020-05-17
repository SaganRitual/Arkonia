import Foundation

class Lungs: OrganProtocol, Protoplasm, HasCapacity, HasMass {
    let capacity: CGFloat

    let maintCostOozePerCap: CGFloat
    let maintCostWorkPerCap: CGFloat
    let mfgCostOozePerCap:   CGFloat
    let mfgCostWorkPerCap:   CGFloat

    let storage = OozeStorage(.lungs)

    var mass: CGFloat { storage.mass }

    init() {
        self.capacity = storage.capacity
        self.maintCostWorkPerCap = storage.maintCostWorkPerCap
        self.maintCostOozePerCap = storage.maintCostOozePerCap
        self.mfgCostWorkPerCap = storage.mfgCostWorkPerCap
        self.mfgCostOozePerCap = storage.mfgCostOozePerCap
    }

    @discardableResult
    func combust(energy cJoulesOfReactant: CGFloat) -> Bool {
        let o2 = cJoulesOfReactant / Ratios.o2_combustJoulesPerCC
        let net = storage.withdraw(o2)
        Debug.log(level: 179) { "Lungs.combust(energy: \(cJoulesOfReactant)) -> \(net) isAlive = (\(net == o2))" }
        return net == o2
    }

    @discardableResult
    func combust(ooze cKgOfReactant: CGFloat) -> Bool {
        let o2 = cKgOfReactant * Ratios.o2_combustOozeKgPerCC
        let net = storage.withdraw(o2)
        Debug.log(level: 179) { "Lungs.combust(ooze: \(cKgOfReactant)) -> \(net) isAlive = (\(net == o2))" }
        return net == o2
    }

    func inhale(_ ccsO2: CGFloat) { storage.deposit(ccsO2) }
}
