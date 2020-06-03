// swiftlint:disable function_body_length
import Foundation

// For doing real energy/mass/work calculations, so I don't have to
// invent a new physics
enum RealWorldConversions {
    static let arkoniaKgPerRealKg:        CGFloat = 0.01
    static let arkoniaCCPerRealCC:        CGFloat = 1
    static let cellsPerRealMeter:         CGFloat = 10
}

enum Ratios {
    static let o2_massO2KgPerCC:        CGFloat = 1.309e-06
    static let ham_massOozeKgPerKg:     CGFloat = 1
    static let vitamin_massOozeKgPerCC: CGFloat = 1
    static let o2_combustJoulesPerCC:   CGFloat = 1
    static let o2_combustOozeKgPerCC:   CGFloat = 1
}

enum MaterialConversions {
    static let hamKgPerOozeKg:         CGFloat = 1
    static let o2CcsPerOozeKg:         CGFloat = 1
    static let vitaminCcsPerOozeKg:    CGFloat = 1
    static let workJoulesCcsPerOozeKg: CGFloat = 1
}

enum WorldConstants {
    static let useCostWorkPerNeuronJoules: CGFloat = 0.5 / 300
    static let useCostOozePerNeuronKg:     CGFloat = 0.5 / 300
}

struct EnergyBudget: HasCapacity {
    let organID:   OrganID
    let chamberID: ChamberID

    let capacity:            CGFloat      // unspecified units
    let compression:         CGFloat
    let contentDensity:      CGFloat      // kg/unit
    let organDensity:        CGFloat      // kg/unit

    let overflowFullness:    CGFloat?
    let underflowFullness:   CGFloat?

    let maintCostOozePerCap: CGFloat
    let maintCostWorkPerCap: CGFloat
    let mfgCostOozePerCap:   CGFloat
    let mfgCostWorkPerCap:   CGFloat
}

extension EnergyBudget {
    static let supersizer: CGFloat = 20

    static func makeEnergyBudgetForChamberedStore(_ organID: OrganID, _ chamberID: ChamberID) -> EnergyBudget {
        switch chamberID {
        case .vitaminB: return EnergyBudget(
            organID:             organID,
            chamberID:           chamberID,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.01,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
            )

        case .vitaminL: return EnergyBudget(
            organID:             organID,
            chamberID:           chamberID,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.01,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
            )

        case .na: fatalError()

        case .ham:    return    makeEnergyBudgetForHamChamber(organID, capacity: 500 * EnergyBudget.supersizer)
        case .fat:    return    makeEnergyBudgetForFatChamber(organID, capacity: 1000 * EnergyBudget.supersizer)
        case .oxygen: return makeEnergyBudgetForOxygenChamber(organID, capacity: 550 * EnergyBudget.supersizer)
        }
    }

    static func makeEnergyBudgetForBasicStore(_ organID: OrganID) -> EnergyBudget {
        switch organID {
        case .energy:   return makeEnergyBudgetForMainEnergyStore(capacity: 900 * EnergyBudget.supersizer)
        case .fatStore: return    makeEnergyBudgetForMainFatStore(capacity: 1000 * EnergyBudget.supersizer)
        case .lungs:    return makeEnergyBudgetForMainOxygenStore(capacity: 800 * EnergyBudget.supersizer)

        case .bone: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )

        case .embryo: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )

        case .leather: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.2,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )

        case .spawn: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )

        case .stomach: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            1,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
        }
    }
}

extension EnergyBudget {
    static func makeEnergyBudgetForMainFatStore(capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             .fatStore,
            chamberID:           .na,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.01,
            organDensity:        0.01,
            overflowFullness:    0.75,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }

    static func makeEnergyBudgetForMainEnergyStore(capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             .energy,
            chamberID:           .na,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.1,
            organDensity:        0.1,
            overflowFullness:    0.25,
            underflowFullness:   0.75,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }

    static func makeEnergyBudgetForMainOxygenStore(capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             .lungs,
            chamberID:           .na,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.1,
            organDensity:        0.05,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }
}

extension EnergyBudget {
    static func makeEnergyBudgetForFatChamber(_ organID: OrganID, capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             organID,
            chamberID:           .fat,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.01,
            organDensity:        0.01,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }

    static func makeEnergyBudgetForHamChamber(_ organID: OrganID, capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             organID,
            chamberID:           .ham,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.1,
            organDensity:        0.1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }

    static func makeEnergyBudgetForOxygenChamber(_ organID: OrganID, capacity: CGFloat) -> EnergyBudget {
        return EnergyBudget(
            organID:             organID,
            chamberID:           .oxygen,
            capacity:            capacity,
            compression:         1,
            contentDensity:      0.1,
            organDensity:        0.1,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )
    }
}
