import CoreGraphics
import Foundation

class Scratchpad {
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellShuttle: CellShuttle?
    weak var dispatch: Dispatch?
    var engagerKey: GridCellKey?
    var isApoptosizing = false
    var name = ""
    weak var parentNet: Net?
    var senseGrid: CellSenseGrid?
    weak var stepper: Stepper?
    var co2Counter: CGFloat = 0

    //swiftlint:disable large_tuple
    func getKeypoints() -> (Scratchpad, Dispatch, Stepper) {
        guard let dp = dispatch, let st = stepper else { fatalError() }
        return (self, dp, st)
    }
    //swiftlint:enable large_tuple

    deinit {
        if let hk = engagerKey as? HotKey { hk.releaseLock() }
        engagerKey = nil

        if let fc = cellShuttle?.fromCell { fc.releaseLock() }
        cellShuttle?.fromCell = nil

        if let tc = cellShuttle?.toCell { tc.releaseLock() }
        cellShuttle?.toCell = nil

        senseGrid?.cells.forEach { ($0 as? HotKey)?.releaseLock() }
        senseGrid = nil
    }
}
