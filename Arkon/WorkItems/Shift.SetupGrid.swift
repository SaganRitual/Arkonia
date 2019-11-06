import Foundation

final class Shift: Dispatchable {

    enum Phase {
        case reserveGridPoints, loadGridInputs
        case calculateShift, releaseGridPoints, shift, postShift
    }

    weak var dispatch: Dispatch!
    var oldGridlet: Gridlet?
    var phase: Phase = .reserveGridPoints
    var runType = Dispatch.RunType.barrier
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)]()
    var shiftTarget: Gridlet?
    var stepper: Stepper { return dispatch.stepper }
    var usableGridlets = [Gridlet]()
    static var uCount = 0

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func callAgain(_ phase: Phase, _ runType: Dispatch.RunType) {
        self.phase = phase
        self.runType = runType
        dispatch.callAgain()
    }

    func getResult() -> Gridlet? { return oldGridlet }

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

    private func loadGridInputs() {
        sensoryInputs = (0..<ArkoniaCentral.cSenseGridlets).map { index in
            let gridPoint = stepper.getGridPointByIndex(index)
            return self.loadGridInput_(gridPoint)
        }
    }

    private func reserveGridPoints() {
        usableGridlets = (0..<ArkoniaCentral.cMotorGridlets).compactMap { index in
            let gridPoint = stepper.getGridPointByIndex(index, absolute: false)
            return reserveGridPoint_(gridPoint)
        }
    }
}

extension Shift {

    private func loadGridInput_(_ step: AKPoint) -> (Double, Double) {
        let inputGridlet = step + stepper.gridlet.gridPosition
        if !Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
            return (Gridlet.Contents.nothing.rawValue, 0)
        }

        let targetGridlet = Gridlet.at(inputGridlet)

        let nutrition: Double

        switch targetGridlet.contents {
        case .arkon:
            nutrition = Double(stepper.metabolism.energyFullness)

        case .manna:
            let sprite = targetGridlet.sprite!
            let manna = Manna.getManna(from: sprite)
            nutrition = Double(manna.energyContentInJoules)

        case .nothing:
            nutrition = 0
        }

        return (targetGridlet.contents.rawValue, nutrition)
    }

    func reserveGridPoint_(_ offset: AKPoint) -> Gridlet? {
        let tp = stepper.gridlet.gridPosition + offset

        guard let targetGridlet = Gridlet.atIf(tp.x, tp.y) else { return nil }

        if targetGridlet.gridletIsEngaged { return nil }

        targetGridlet.gridletIsEngaged = true
        return targetGridlet
    }
}
