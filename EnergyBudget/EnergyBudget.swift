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

struct MannaContent: HasSelectableStore {
    typealias StoreType = CGFloat

    let bone:    CGFloat = 1
    let ham:     CGFloat = 300   // Manna contains ham; arkons convert it directly to energy
    let leather: CGFloat = 1
    let o2:      CGFloat = 1

    func selectStore(_ organID: OrganID) -> CGFloat? {
        switch organID {
        case .bone:     return bone
        case .energy:   return ham
        case .fatStore: return nil
        case .leather:  return leather
        case .lungs:    return o2
        default: fatalError()
        }
    }
}

extension EnergyBudget {
    static func makeEnergyBudgetForChamberedStore(_ organID: OrganID, _ chamberID: ChamberID) -> EnergyBudget {
        switch chamberID {
        case .fat: return EnergyBudget(
            organID:             organID,
            chamberID:           chamberID,
            capacity:            300,
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

        case .ham: return EnergyBudget(
            organID:             organID,
            chamberID:           chamberID,
            capacity:            500,
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

        case .oxygen: return EnergyBudget(
            organID:             organID,
            chamberID:           chamberID,
            capacity:            800,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.05,
            overflowFullness:    nil,
            underflowFullness:   nil,
            maintCostOozePerCap: 1,
            maintCostWorkPerCap: 1,
            mfgCostOozePerCap:   1,
            mfgCostWorkPerCap:   1
        )

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
        }
    }

    static func makeEnergyBudgetForBasicStore(_ organID: OrganID) -> EnergyBudget {
        switch organID {
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

        case .energy: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            500,
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

        case .fatStore: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            300,
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

        case .lungs: return EnergyBudget(
            organID:             organID,
            chamberID:           .na,
            capacity:            800,
            compression:         1,
            contentDensity:      1,
            organDensity:        0.05,
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
