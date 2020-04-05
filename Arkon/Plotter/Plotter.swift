import Foundation

class Plotter {
    weak var scratch: Scratchpad?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
    }

    deinit {
        Debug.log(level: 147) { "Plot deinit \(six(scratch?.name))" }
    }

    func plot(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        Debug.log(level: 156) { "plot" }

        var sensoryInputs: [Double]!

        func a() {
            if ch.sensesConnector == nil { ch.sensesConnector = SensesConnector(ch) }

            ch.sensesConnector!.connect(b)
        }

        func b() {
//            let delay = TimeInterval.random(in: 0.01..<0.02)
//            let randomer = TimeInterval.random(in: 1..<5)
//            Net.dispatchQueue.asyncAfter(deadline: .now() + delay * randomer, execute: c)
            Net.dispatchQueue.async(execute: c)
        }

        func c() {
            self.setRoute(ch.gridInputs, sg) { ch.cellShuttle = $0; d()  }
        }

        // 97298509+
        func d() { Grid.arkonsPlaneQueue.async(execute: e) }

        func e() {
            sg.releaseNonStageCells(keep: ch.cellShuttle!.toCell!)
            ch.engagerKey = nil

            // As of 2020.03.29, this goes out to ComputeMove.computeMove.b,
            // where we're jumping out to the tickLife queue anyway, so no need to
            // re-queue this as we do the others
            onComplete()
        }

        a()
    }
}
