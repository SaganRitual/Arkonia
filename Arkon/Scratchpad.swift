class Scratchpad {
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellConnector: HotKey?
    var cellTaxi: CellTaxi?
    weak var dispatch: Dispatch?
    var isApoptosizing = false
    var isEngaged: Bool { cellConnector != nil }
    weak var parentNet: Net?
    weak var stepper: Stepper?
    var worldStats: World.StatsCopy?

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple
}
