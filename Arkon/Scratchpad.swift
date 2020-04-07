import CoreGraphics
import Foundation

enum DispatchQueueID: Int {
    case arkonDispatch, arkonsPlane, census, clock, energyReserve, mannaPlane
    case net, sceneUpdate, tickLife, unspecified
}

class Scratchpad {
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellShuttle: CellShuttle?
    var spreader = Int.random(in: 0..<10)
    var spreading = 0
    weak var dispatch: Dispatch?
    var engagerKey: GridCell?
    var isApoptosizing = false
    var name = ArkonName.makeName(.nothing, 0)
    weak var parentNet: Net?
    var plotter: Plotter?
    var senseGrid: CellSenseGrid?
    var sensesConnector: SensesConnector?
    weak var stepper: Stepper!
    var co2Counter: CGFloat = 0
    var debugTimer: __uint64_t = 0
    var debugStart: __uint64_t = 0
    var debugStop: __uint64_t = 0

    var gridInputs = [Double]()

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0
    var dispatchQueueID = DispatchQueueID.arkonDispatch

    deinit {
        Debug.log(level: 146) { "Scratchpad deinit for \(name)" }
        if let hk = engagerKey {
            Debug.log(level: 146) { "release engager key for \(name)" }
            hk.releaseLock(dispatchQueueID)
            engagerKey = nil
        }

        if let fc = cellShuttle?.fromCell {
            Debug.log(level: 146) { "release fromCell for \(name)" }
            fc.releaseLock(dispatchQueueID)
            cellShuttle?.fromCell = nil
        }

        if let tc = cellShuttle?.toCell {
            Debug.log(level: 146) { "release toCell for \(name)" }
            tc.releaseLock(dispatchQueueID)
            cellShuttle?.toCell = nil
        }
    }
}
