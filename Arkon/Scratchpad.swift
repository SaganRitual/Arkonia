import CoreGraphics
import Foundation

enum DispatchQueueID: Int {
    case arkonDispatch, arkonsPlane, census, clock, energyReserve, mannaPlane
    case net, sceneUpdate, tickLife, unspecified
}

class Scratchpad {
    var babyBumpIsShowing = false
    var battle: (Stepper, Stepper)?
    var canSpawn = false
    var cellShuttle: CellShuttle?
    weak var dispatch: Dispatch?
    var engagerKey: GridCell?
    var isRescheduled = false
    var isSpawning = false
    var jumpSpeed = 0.0
    var jumpSpec: JumpSpec!
    var name = ArkonName.empty
    weak var parentNet: Net?
    var plotter: Plotter?
    var senseGrid: CellSenseGrid?
    var sensesConnector: SensesConnector?
    weak var stepper: Stepper!
    var debugTimer: __uint64_t = 0
    var debugStart: __uint64_t = 0
    var debugStop: __uint64_t = 0

    var gridInputs = [Double]()

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0

    func apoptosize(_ catchDumbMistakes: DispatchQueueID) {
        Debug.log(level: 146) { "Scratchpad deinit for \(name)" }
        if let fc = cellShuttle?.fromCell {
            Debug.log(level: 169) { "release fromCell \(fc.gridPosition) for \(name)" }
            fc.releaseLock(catchDumbMistakes)
            cellShuttle?.fromCell = nil
        }

        if let tc = cellShuttle?.toCell {
            Debug.log(level: 169) { "release toCell \(tc.gridPosition) for \(name)" }
            tc.releaseLock(catchDumbMistakes)
            cellShuttle?.toCell = nil
        }

        if let hk = engagerKey {
            Debug.log(level: 169) { "release engager key \(hk.gridPosition) for \(name)" }
            hk.releaseLock(catchDumbMistakes)
            engagerKey = nil
        }

        if let sg = senseGrid {
            Debug.log(level: 169) {
                let cell = (sg.cells[0] as? GridCell)!
                return "release senseGrid centered at \(cell.gridPosition) for \(name)"
            }

            sg.reset(catchDumbMistakes)
            sg.cells[0] = CellSenseGrid.nilKey
        }
    }
}
