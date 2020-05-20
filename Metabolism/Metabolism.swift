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
    let energy =   OozeStorage(.energy)
    let fatStore = OozeStorage(.fatStore)
    let leather =  OozeStorage(.leather)
    let lungs =    Lungs()
    let stomach =  ChamberedStore(.stomach, 1)

    var embryo: ChamberedStore? = ChamberedStore(.embryo, 2)
    var spawn: ChamberedStore?

    let bodyPerCycleEnergyCost: CGFloat
    let bodyPerCycleOozeCost:   CGFloat

    let allOrgans: [Protoplasm]
    let secondaryStores: [OrganID]

    lazy var massCenters = allOrgans.compactMap { $0 as? HasMass }
    var mass: CGFloat { massCenters.reduce(0) { $0 + $1.mass } }

    var asphyxiation: CGFloat { 1 - lungs.storage.fullness }
    var hunger: CGFloat { 1 - stomach.hamStore.fullness }

    init(cNeurons: Int) {
        let cn = CGFloat(cNeurons)
        let brainPerCycleEnergyCost = cn * WorldConstants.useCostWorkPerNeuronJoules
        let brainPerCycleOozeCost   = cn * WorldConstants.useCostOozePerNeuronKg

        allOrgans = [
            bone, embryo!, energy, fatStore, leather, lungs, stomach
        ]

        secondaryStores = [.bone, .energy, .fatStore, .leather, .lungs]

        let capacityCenters = allOrgans.compactMap { $0 as? HasCapacityCosts }

        let gutPerCycleEnergyCost = capacityCenters.reduce(0) { $0 + $1.maintCostWorkPerCap }
        let gutPerCycleOozeCost   = capacityCenters.reduce(0) { $0 + $1.maintCostOozePerCap }

        bodyPerCycleEnergyCost = brainPerCycleEnergyCost + gutPerCycleEnergyCost
        bodyPerCycleOozeCost = brainPerCycleOozeCost + gutPerCycleOozeCost

        ChamberedStore.fill(embryo!)
    }

    func applyFixedMetabolicCosts() -> Bool {
        var alive = true

        Debug.log(level: 179) {
            "enter applyFixedMetabolicCosts()"
                + " -> be = \(self.bodyPerCycleEnergyCost)"
                + ", bo = \(self.bodyPerCycleOozeCost)"
        }

        defer {
            Debug.log(level: 179) { "exit applyFixedMetabolicCosts(); alive = \(alive)" }
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

    // The spawn embryo and all of my own reserves must be full before I can
    // give birth
    func canSpawn() -> Bool {
        guard let spawn = self.spawn else { return false }

        let organIDs: [OrganID] = [.fatStore, .energy, .lungs]

        // To spawn, your spawn embryo must be full, and...
        let spawnEmbryoReady = organIDs.map { spawn.selectStore($0)! }.allSatisfy { $0.isFull }

        // Your own reserves must be nearly full -- I'd go with completely full,
        // but we're checking this just after we've applied the fixed metabolic costs,
        // so none of the stores will be compltely full. I'm fine with full minus
        // one cycle of fixed costs. It's easier than trying to change the order of
        // this check and the fixed cost application.
        let reservesReady = organIDs.map { self.selectStore($0)! }.allSatisfy { $0.fullness > 0.95 }

        return spawnEmbryoReady && reservesReady
    }

    func detachBirthEmbryo() { embryo = nil }
    func detachSpawnEmbryo() {
        spawn = nil

        // Spawning is expensive
        let organIDs: [OrganID] = [.fatStore, .energy, .lungs]
        organIDs.forEach {
            guard let store = self.selectStore($0) else { fatalError() }
            store.withdraw(store.level / 2)
        }
    }

    func eat(_ mannaContent: EnergyBudget.MannaContent) {
        for id in secondaryStores {
            guard let mannaStoreLevel = mannaContent.selectStore(id),
                  let compartment = stomach.selectStore(id) else { continue }

            compartment.deposit(mannaStoreLevel)

            Debug.log(level: 179) {
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
