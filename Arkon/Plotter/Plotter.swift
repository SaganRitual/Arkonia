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
//            let delay = TimeInterval.random(in: 0.01..<0.02)
//            let randomer = TimeInterval.random(in: 1..<5)
//            Net.dispatchQueue.asyncAfter(deadline: .now() + delay * randomer, execute: c)
            Net.dispatchQueue.async { c(.net) }
        }

        func c(_ catchDumbMistakes: DispatchQueueID) {
            self.setRoute(scratch.gridInputs, sg) {
                self.scratch.cellShuttle = $0; self.scratch.jumpSpeed = $1; d()  }
        }

        // 97298509+
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
