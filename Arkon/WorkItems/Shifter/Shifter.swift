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

    lazy var safeCell: SafeCell? = {
        dispatch.gridCellConnector =
            stepper.gridCell.engage(owner: stepper.name, require: false)

        return dispatch.gridCellConnector as? SafeCell
    }()

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
//        print("shift callAgain \(six(stepper.name))")
        self.phase = phase
        self.runType = runType
        dispatch.callAgain()
//        print("shift callAgain exit \(six(stepper.name))")
    }

    func go() {
        if safeCell == nil { return }

//        print("aShift \(six(stepper.name))")
        self.aShift()
    }
}

extension Shifter {
    func aShift() {
        switch phase {
        case .reserveGridPoints:
//            print("reserveGridPoints pre \(six(stepper.name))")
            reserveGridPoints()
//            print("reserveGridPoints post \(six(stepper.name))")
            callAgain(.loadGridInputs, .concurrent)
//            print("reserveGridPoints call again \(six(stepper.name))")

        case .loadGridInputs:
//            print("loadGridInputs \(six(stepper.name))")
            loadGridInputs()
            callAgain(.calculateShift, .concurrent)

        case .calculateShift:
//            print("calculateShift \(six(stepper.name))")
            calculateShift()
            callAgain(.moveSprite, .concurrent)

        case .moveSprite:
//            print("moveSprite \(six(stepper.name))")
            moveSprite { didMove in
                self.callAgain(didMove ? .shift : .postShift, .barrier)
            }

        case .shift:
//            print("shift \(six(stepper.name))")
            shift()
            callAgain(.postShift, .barrier)

        case .postShift:
//            print("postShift \(six(stepper.name))")
            postShift()
        }
    }
}
