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
    weak var stepper: Stepper?
    var stillCounter: CGFloat = 0

    deinit {
        Debug.log("~Scratchpad", level: 45)
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
