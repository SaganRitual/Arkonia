import Foundation

final class Shift: Dispatchable {

    enum Phase { case configureGrid, calculateShift, shift, postShift }

    weak var dispatch: Dispatch!
    var oldGridlet: GridletCopy?
    var phase: Phase = .configureGrid
    var sensoryInputs = [(Double, Double)]()
    var shiftTarget: AKPoint?
    var stepper: Stepper { return dispatch.stepper }
    var usableGridOffsets = [AKPoint]()

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func getResult() -> GridletCopy? { return oldGridlet }

    func go() { self.aShift() }

}

extension Shift {
    func aShift() {
        switch phase {
        case .configureGrid:
            setupGrid()

            phase = .calculateShift
            dispatch.callAgain()

        case .calculateShift:
            calculateShift()

            phase = .shift
            dispatch.callAgain()

        case .shift:
            shift()

        case .postShift:
            postShift()
        }
    }

    func setupGrid() {
        reserveGridPoints()
        loadGridInputs()
    }

    private func loadGridInputs() {
        sensoryInputs = Grid.gridInputs.map { step in
            return self.loadGridInputs_(step)
        }
    }

    private func reserveGridPoints() {
        usableGridOffsets = Grid.moves.compactMap { offset in
            reserveGridPoints_(offset)
        }
    }
}

extension Shift {

    private func loadGridInputs_(_ step: AKPoint) -> (Double, Double) {
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

        case .nothing: fallthrough
        case .unknown:
            nutrition = 0
        }

        return (targetGridlet.contents.rawValue, nutrition)
    }

    func reserveGridPoints_(_ offset: AKPoint) -> AKPoint? {
        let targetGridPoint = stepper.gridlet.gridPosition + offset

        if Gridlet.isOnGrid(targetGridPoint.x, targetGridPoint.y) {
            let targetGridlet = Gridlet.at(targetGridPoint)

            if !targetGridlet.gridletIsEngaged {
                targetGridlet.gridletIsEngaged = true
                return offset
            }
        }

        return nil
    }
}
