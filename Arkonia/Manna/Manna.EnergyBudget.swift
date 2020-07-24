import Foundation

extension EnergyBudget {
    struct MannaContent: HasSelectableStore {
        // swiftlint:disable nesting
        // "Nesting Violation: Types should be nested at most 1 level deep (nesting)"
        typealias StoreType = CGFloat
        // swiftlint:enable nesting

        let bone:    CGFloat = 1
        let ham:     CGFloat = 100   // Manna contains ham; arkons convert it directly to energy
        let leather: CGFloat = 1
        let o2:      CGFloat = 70

        let maturityLevel: CGFloat
        let scale: CGFloat
        let supersizerScale: CGFloat = 0.9
        let temperature: CGFloat

        init(_ maturityLevel: CGFloat = 1, _ temperature: CGFloat) {
            self.maturityLevel = maturityLevel
            self.temperature = temperature
            self.scale = EnergyBudget.supersizer * supersizerScale * maturityLevel * temperature
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
