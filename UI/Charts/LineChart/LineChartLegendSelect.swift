import SwiftUI

class ChartLegendSelect: ObservableObject {
    @Published var dataSelectors = [Bool]()

    init(_ cSelectors: Int) {
        (0..<cSelectors).forEach { _ in dataSelectors.append(true) }
    }

    func toggle(_ selectorSS: Int) {
        dataSelectors[selectorSS] = !dataSelectors[selectorSS]
    }
}
