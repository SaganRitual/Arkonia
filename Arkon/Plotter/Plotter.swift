class Plotter {
    weak var scratch: Scratchpad?
    let sensesLoader: SensesLoader

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.sensesLoader = SensesLoader(scratch)
    }

    deinit {
        Debug.log(level: 147) { "Plot deinit \(six(scratch?.name))" }
    }

    func plot(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        Debug.log(level: 156) { "plot" }

        var sensoryInputs: [Double]!

        func a() { sensesLoader.loadSenses { sensoryInputs = $0; b() } }

        func b() { Net.dispatchQueue.async(execute: c) }

        func c() {
            self.setRoute(sensoryInputs, sg) { ch.cellShuttle = $0; d()  }
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
