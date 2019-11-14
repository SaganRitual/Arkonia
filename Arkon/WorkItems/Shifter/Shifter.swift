import Foundation

final class Shifter: Dispatchable {

    enum Phase {
        case reserveGridPoints, loadGridInputs
        case calculateShift
        case moveSprite, shift, postShift
    }

    weak var dispatch: Dispatch!

    var phase: Phase = .reserveGridPoints
    var runType = Dispatch.RunType.concurrent
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)?]()
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch.callAgain()
    }

    func go() {
        guard let gcc = stepper.gridCell.engage(owner: stepper.name, require: false)
            else { return }

        dispatch.gridCellConnector = gcc
        self.aShift()

    }
}

extension Shifter {
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
            callAgain(.moveSprite, .concurrent)

        case .moveSprite:
            moveSprite { didMove in
                self.callAgain(didMove ? .shift : .postShift, .barrier)
            }

        case .shift:
            shift()
            callAgain(.postShift, .barrier)

        case .postShift:
            postShift()
        }
    }
}
