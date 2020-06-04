import Foundation

extension EnergyBudget {
    struct MannaContent: HasSelectableStore {
        // swiftlint:disable nesting
        // "Nesting Violation: Types should be nested at most 1 level deep (nesting)"
        typealias StoreType = CGFloat
        // swiftlint:enable nesting

        let bone:    CGFloat = 1
        let ham:     CGFloat = 1000   // Manna contains ham; arkons convert it directly to energy
        let leather: CGFloat = 1
        let o2:      CGFloat = 700

        let maturityLevel: CGFloat
        let scale: CGFloat
        let seasonalFactors: CGFloat

        init(_ maturityLevel: CGFloat = 1, _ seasonalFactors: CGFloat) {
            self.maturityLevel = maturityLevel
            self.seasonalFactors = seasonalFactors
            self.scale = EnergyBudget.supersizer * maturityLevel * seasonalFactors
        }

        func selectStore(_ organID: OrganID) -> CGFloat? {
            switch organID {
            case .bone:     return bone * scale
            case .energy:   return ham * scale
            case .fatStore: return nil
            case .leather:  return leather * scale
            case .lungs:    return o2 * scale
            default: fatalError()
            }
        }
    }
}
