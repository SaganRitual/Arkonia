class Scratchpad {
    var isAwaitingWakeup = false
    var canSpawn = false
    var battle: (Stepper, Stepper)?
    weak var dispatch: Dispatch?
    var gridCellConnector: SafeConnectorProtocol? {
        willSet {
            let t: String
            switch newValue {
            case is SafeCell: t = "SafeCell"
            case is SafeSenseGrid: t = "SafeSenseGrid"
            case is SafeStage: t = "SafeStage"
            case nil: t = "nothing"
            default: fatalError()
            }
            Log.L.write("gcc reset \(t) for \(six(stepper?.name))", level: 0)
        }
    }
    var isAlive = false
    var isApoptosizing = false
    var launched = false
    weak var stepper: Stepper?
    var worldStats: World.StatsCopy?

    func getGridConnector<T: SafeConnectorProtocol>(require: Bool = false) -> T? {
        guard let c = gridCellConnector, let connector = c as? T else {
            if require { preconditionFailure() }
            return nil
        }

        return connector
    }

    func getCellConnector(require: Bool = false) -> SafeCell? {
        return getGridConnector(require: require)
    }

    func getSenseGridConnector(require: Bool = false) -> SafeSenseGrid? {
        return getGridConnector(require: require)
    }

    func getStageConnector(require: Bool = false) -> SafeStage? {
        return getGridConnector(require: require)
    }

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple
}
