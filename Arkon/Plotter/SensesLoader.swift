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
            let connectors = (
                self.sensesConnector.gridInputs +
                self.sensesConnector.nonGridInputs
            )

            let sensoryInputs = connectors.map { $0.load() }

            // Make sure all our inputs are in proper range
            precondition(sensoryInputs.first(where: { $0 < -1 || $0 >= 1 }) == nil)

            onComplete(sensoryInputs)
        }
    }
}
