import Foundation

class SensesLoader {
    weak var scratch: Scratchpad?
    let sensesConnector: SensesConnector

    init(_ scratch: Scratchpad) {
        self.scratch = scratch

        sensesConnector = SensesConnector(scratch)
    }

    deinit {
        Debug.log(level: 147) { "SensesLoader deinit \(six(scratch?.name))" }
    }

    func loadSenses(_ onComplete: @escaping ([Double]) -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        sensesConnector.connectGridInputs(from: sg) {
            let gridSelectors: [Double] = self.sensesConnector.gridInputs.map { $0.loadSelector() }

            let gridNutrition: [Double] = self.sensesConnector.gridInputs.map { $0.loadNutrition() }

            let nonGridInputs: [Double] = self.sensesConnector.nonGridInputs.map { $0.load() }

//            let v = self.sensesConnector.nonGridInputs[3].load()
//            Debug.histogrize(v, scale: 10, inputRange: 0..<1)

            let sensoryInputs = gridSelectors + gridNutrition + Array(nonGridInputs[0..<3])

            // Make sure all our inputs are in proper range
            precondition(sensoryInputs.first(where: { $0 < -1 || $0 >= 1 }) == nil)

            onComplete(sensoryInputs)
        }
    }
}
