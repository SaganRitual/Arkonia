import Foundation

final class Shift: Dispatchable {

    enum Phase {
        case reserveGridPoints, loadGridInputs
        case calculateShift, getGridletCopies, releaseGridPoints, shift, postShift
    }

    weak var dispatch: Dispatch!
    var gridletConnector: Gridlet.Connector?
    var phase: Phase = .reserveGridPoints
    var runType = Dispatch.RunType.barrier
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)]()
    var shiftTarget: Gridlet?
    var stepper: Stepper { return dispatch.stepper }
    var engagedGridlets = [Engager]()
    static var uCount = 0

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
        stepper.shiftTracker = ShiftTracker()
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch.callAgain()
    }

    func getResult() -> ShiftTracker { return stepper.shiftTracker }

    func go() { self.aShift() }
}

extension Shift {
    func aShift() {
        switch phase {
        case .reserveGridPoints:
            reserveGridPoints()
            callAgain(.loadGridInputs, .concurrent)

        case .loadGridInputs:
            loadGridInputs()
            callAgain(.calculateShift, .concurrent)

        case .calculateShift:
            calculateShift()
            callAgain(.getGridletCopies, .barrier)

        case .getGridletCopies:
            getGridletCopies()
            callAgain(.releaseGridPoints, .barrier)

        case .releaseGridPoints:
            releaseGridPoints()
            callAgain(.shift, .barrier)

        case .shift:
            shift {
                self.callAgain(.postShift, .barrier)
            }

        case .postShift:
            postShift()
        }
    }
}
