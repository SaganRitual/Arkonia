import Foundation

final class Shift: Dispatchable {

    enum Phase {
        case reserveGridPoints, loadGridInputs
        case calculateShift, releaseGridPoints
        case moveSprite, shift, postShift
    }

    weak var dispatch: Dispatch!
    var gridletEngager: Gridlet.Engager {
        get { return dispatch.gridletEngager }
        set {
//            print("set engager", newValue.owner)
            dispatch.gridletEngager = newValue }
    }

    var didMove = false
    var phase: Phase = .reserveGridPoints
    var runType = Dispatch.RunType.barrier
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)?]()
    var shiftTarget: GridletCopy?
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
        guard let e = stepper.gridlet.engage(owner: stepper.name, require: true)
            else {
                print("alpha")
                return }

        print("beta")

        dispatch.gridletEngager = e
        print("gamow")
        self.aShift()
        print("harpo")
    }
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
            callAgain(.releaseGridPoints, .concurrent)

        case .releaseGridPoints:
            releaseGridPoints()
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
