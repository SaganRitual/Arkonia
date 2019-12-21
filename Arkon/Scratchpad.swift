import CoreGraphics

class Scratchpad {
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellShuttle: CellShuttle?
    var debugEngage = DebugEngage.nothing
    var debugEngageCRetry = 0
    var debugReport = [String]()
    weak var dispatch: Dispatch?
    var engagerKey: GridCellKey?
    var isApoptosizing = false
    weak var parentNet: Net?
    var serializer = 0
    weak var stepper: Stepper?
    var stillCounter: CGFloat = 0
    var worldStats: World.StatsCopy?

    deinit {
        Log.L.write("~Scratchpad", level: 45)
        guard let ek = engagerKey as? HotKey else { return }
        ek.contents = .nothing
        ek.sprite = nil
    }

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple
}
