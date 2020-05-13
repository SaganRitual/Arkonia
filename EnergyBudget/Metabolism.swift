import Foundation

enum OrganID {
    case bone
    case embryo
    case fatStore
    case leather
    case lungs
    case energy
    case spawn
    case stomach
}

class Metabolism: HasSelectableStore {
    typealias StoreType = OozeStorage

    let bone =     OozeStorage(.bone)
    let embryo =   ChamberedStore(.embryo, 2)
    let energy =   OozeStorage(.energy)
    let fatStore = OozeStorage(.fatStore)
    let leather =  OozeStorage(.leather)
    let lungs =    Lungs()
    let spawn =    ChamberedStore(.spawn, 2)
    let stomach =  ChamberedStore(.stomach, 1)

    let bodyPerCycleEnergyCost: CGFloat
    let bodyPerCycleOozeCost:   CGFloat

    let allOrgans: [Protoplasm]
    let secondaryStores: [OrganID]

    lazy var massCenters = allOrgans.compactMap { $0 as? HasMass }
    var mass: CGFloat { massCenters.reduce(0) { $0 + $1.mass } }

    init(cNeurons: Int) {
        let cn = CGFloat(cNeurons)
        let brainPerCycleEnergyCost = cn * WorldConstants.useCostWorkPerNeuronJoules
        let brainPerCycleOozeCost   = cn * WorldConstants.useCostOozePerNeuronKg

        allOrgans = [
            bone, embryo, energy, fatStore, leather, lungs, spawn, stomach
        ]

        secondaryStores = [.bone, .fatStore, .energy, .leather, .lungs]

        let capacityCenters = allOrgans.compactMap { $0 as? HasCapacityCosts }

        let gutPerCycleEnergyCost = capacityCenters.reduce(0) { $0 + $1.maintCostWorkPerCap }
        let gutPerCycleOozeCost   = capacityCenters.reduce(0) { $0 + $1.maintCostOozePerCap }

        bodyPerCycleEnergyCost = brainPerCycleEnergyCost + gutPerCycleEnergyCost
        bodyPerCycleOozeCost = brainPerCycleOozeCost + gutPerCycleOozeCost

        ChamberedStore.fill(embryo)
    }

    func applyFixedMetabolicCosts() -> Bool {
        var alive = true

        Debug.log(level: 179) {
            "enter applyFixedMetabolicCosts()"
                + " -> be = \(self.bodyPerCycleEnergyCost)"
                + ", bo = \(self.bodyPerCycleOozeCost)"
        }

        defer {
            Debug.log(level: 180) { "exit applyFixedMetabolicCosts(); alive = \(alive)" }
        }

        for maintainBody: (() -> Bool) in [
            {
                let start = self.energy.level
                defer { Debug.log(level: 180) { "maintainBody(energy); energy start \(start) result \(self.energy.level) alive = \(alive)" } }
                alive = self.energy.withdraw(self.bodyPerCycleEnergyCost) == self.bodyPerCycleEnergyCost
                return alive
            },
            {
                let start = self.fatStore.level
                defer { Debug.log(level: 180) { "maintainBody(material); fatStore start \(start) result \(self.fatStore.level) alive = \(alive)" } }
                alive = self.fatStore.withdraw(self.bodyPerCycleOozeCost) == self.bodyPerCycleOozeCost
                return alive
            },
            {
                let start = self.lungs.storage.level
                defer { Debug.log(level: 180) { "maintainBody(lungs.1); lungs start \(start) result \(self.lungs.storage.level) alive = \(alive)" } }
                alive = self.lungs.combust(energy: self.bodyPerCycleEnergyCost)
                return alive
            },
            {
                let start = self.lungs.storage.level
                defer { Debug.log(level: 180) { "maintainBody(lungs.2); lungs start \(start) result \(self.lungs.storage.level) alive = \(alive)" } }
                alive = self.lungs.combust(ooze: self.bodyPerCycleOozeCost)
                return alive
            }
        ] {
            alive = maintainBody()
            if !alive { break }
        }

        return alive
    }

    func eat() {
        let manna = MannaContent()

        for id in secondaryStores {
            guard let mannaStoreLevel = manna.selectStore(id),
                  let compartment = selectStore(id) else { continue }

            compartment.deposit(mannaStoreLevel)

            Debug.log(level: 180) {
                "absorb \(mannaStoreLevel) into \(id), result level \(compartment.level)"
            }
        }
    }

    func selectStore(_ organID: OrganID) -> OozeStorage? {
        switch organID {
        case .bone:     return bone
        case .energy:   return energy
        case .fatStore: return fatStore
        case .leather:  return leather
        case .lungs:    return lungs.storage

        default: fatalError()
        }
    }
}
