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

        func d() { Grid.serialQueue.timeProfileAsync(execute: e) }

        func e() {
            sg.releaseNonStageCells(keep: ch.cellShuttle!.toCell!)
            ch.engagerKey = nil
            Debug.log(level: 156) {
                "computeMove \(six(ch.name)) ->"
                + " \(ch.cellShuttle!.toCell?.contents ?? .invalid) to"
                + " \(ch.cellShuttle!.toCell?.gridPosition ?? AKPoint.zero),"
                + " \(ch.cellShuttle!.fromCell?.contents ?? .invalid) from"
                + " \(ch.cellShuttle!.fromCell?.gridPosition ?? AKPoint.zero)"
            }
            onComplete()
        }

        a()
    }
}
