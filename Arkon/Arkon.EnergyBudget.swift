import Foundation

extension EnergyBudget {
    struct ArkonContent {
        // swiftlint:disable nesting
        // "Nesting Violation: Types should be nested at most 1 level deep (nesting)"
        typealias StoreType = CGFloat
        // swiftlint:enable nesting

        let bone:    CGFloat = 1
        let ham:     CGFloat = 1000   // Manna contains ham; arkons convert it directly to energy
        let leather: CGFloat = 1
        let o2:      CGFloat = 700

        init(_ stepper: Stepper) {
        }

        func selectStore(_ organID: OrganID) -> CGFloat? {
            return 0
        }
    }
}
