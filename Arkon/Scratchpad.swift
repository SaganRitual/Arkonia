class Scratchpad {
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellTaxi: cellTaxi_?

    var debugEngage = DebugEngage.nothing
    var debugEngageCRetry = 0
    weak var dispatch: Dispatch?
    var engagerKey: GridCellKey?
    var isApoptosizing = false
    weak var parentNet: Net?
    weak var stepper: Stepper?
    var stillCounter = 0
    var worldStats: World.StatsCopy?

    deinit {
        Log.L.write("~Scratchpad", level: 45)
    }

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple
}
