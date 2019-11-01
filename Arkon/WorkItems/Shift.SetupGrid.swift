import Foundation

final class Shift: Dispatchable {

    enum Phase {
        case reserveGridPoints, loadGridInputs
        case calculateShift, releaseGridPoints, shift, postShift
    }

    weak var dispatch: Dispatch!
    var oldGridlet: GridletCopy?
    var phase: Phase = .reserveGridPoints
    var runAsBarrier: Bool = true
    var senseData = [Double]()
    var sensoryInputs = [(Double, Double)]()
    var shiftTarget: Gridlet?
    var stepper: Stepper { return dispatch.stepper }
    var usableGridlets = [Gridlet]()

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func callAgain(_ phase: Phase, _ runAsBarrier: Bool) {
        self.phase = phase
        self.runAsBarrier = runAsBarrier
        dispatch.callAgain()
    }

    func getResult() -> GridletCopy? { return oldGridlet }

    func go() { self.aShift() }

}

extension Shift {
    func aShift() {
        switch phase {
        case .reserveGridPoints:
            reserveGridPoints()
            loadGridInputs()
            callAgain(.calculateShift, false)

        case .calculateShift:
            calculateShift()
            callAgain(.releaseGridPoints, true)

        case .releaseGridPoints:
            releaseGridPoints()
            callAgain(.shift, false)

        case .shift:
            shift()

        case .postShift:
            postShift()

        case .loadGridInputs: fatalError()
        }
    }

    private func loadGridInputs() {
        sensoryInputs = Grid.gridInputs.map { step in
            return self.loadGridInput_(step)
        }
    }

    private func reserveGridPoints() {
        usableGridlets = Grid.moves.compactMap { offset in
            reserveGridPoint_(offset)
        }
    }
}

extension Shift {

    private func loadGridInput_(_ step: AKPoint) -> (Double, Double) {
        let inputGridlet = step + stepper.gridlet.gridPosition
        if !Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
            return (Gridlet.Contents.nothing.rawValue, -1e6)
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
