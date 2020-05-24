import Foundation

class Plotter {
//    static let histogram = Debug.Histogram()
    weak var scratch: Scratchpad!

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    deinit {
        Debug.log(level: 147) { "Plot deinit \(six(scratch?.name))" }
    }

    func plot(_ onComplete: @escaping () -> Void) {
        let sg = (scratch.senseGrid)!

        Debug.log(level: 156) { "plot" }

        var sensoryInputs: [Double]!

        func a() {
            if scratch.sensesConnector == nil { scratch.sensesConnector = SensesConnector(scratch) }

            scratch.sensesConnector!.connect(b)
        }

        func b() {
            Net.dispatchQueue.async { c(.net) }
        }

        func c(_ catchDumbMistakes: DispatchQueueID) {
            self.setRoute(scratch.senseInputs, sg) {
                self.scratch.cellShuttle = $0; self.scratch.jumpSpeed = $1; d()  }
        }

        func d() { Grid.arkonsPlaneQueue.async { e(.arkonsPlane) } }

        func e(_ catchDumbMistakes: DispatchQueueID) {
            sg.reset(keep: scratch.cellShuttle!.toCell!, catchDumbMistakes)

            // As of 2020.03.29, this goes out to ComputeMove.computeMove.b,
            // where we're jumping out to the tickLife queue anyway, so no need to
            // re-queue this as we do the others
            onComplete()
        }

        a()
    }
}
