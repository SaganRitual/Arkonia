class Scratchpad {
    var isAwaitingWakeup = false
    var canSpawn = false
    var battle: (Stepper, Stepper)?
    weak var dispatch: Dispatch?
    var gridConnector: GridConnectorProtocol?
    var isApoptosizing = false
    var isEngaged: Bool { gridConnector != nil }
    var launched = false
    weak var parentNet: Net?
    weak var stepper: Stepper?
    var worldStats: World.StatsCopy?

    func getGridConnector<T: GridConnectorProtocol>(require: Bool = false) -> T? {
        guard let c = gridConnector, let connector = c as? T else {
            precondition(require == false)
            return nil
        }

        return connector
    }

    func getCellConnector(require: Bool = false) -> SafeCell? {
        return getGridConnector(require: require)
    }

    func getSensesConnector(require: Bool = false) -> SafeSenseGrid? {
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

    func resetGridConnector() { setGridConnector(nil) }

    func setGridConnector(_ gridConnector: GridConnectorProtocol?) {
        self.gridConnector = gridConnector
    }
}
