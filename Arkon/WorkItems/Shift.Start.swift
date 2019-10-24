import Foundation

extension Stepper {
    func shiftStart() {
        shifter = Shifter(stepper: self)
        shifter!.start(gridlet)
    }
}

class Shifter {
    var sensoryInputs = [(Double, Double)]()
    weak var stepper: Stepper!
    var usableGridOffsets = [AKPoint]()

    init(stepper: Stepper) { self.stepper = stepper }

    deinit {
//        print("~Shift")
    }
}

typealias LockVoid = Dispatch.Lockable<Void>

extension Shifter {
    func start(_ gridlet: Gridlet) {
        Grid.lock({ [unowned self] () -> [Void]? in

            self.start_()
            return nil

        }, { [unowned self] (_ nothing: [Void]?) -> Void in
            self.stepper.calculateShift()
        },
           .continueBarrier
        )
    }

    private func start_() {
        reserveGridPoints_()
        loadGridInputs_()
    }

    private func loadGridInputs_() {
        sensoryInputs = Grid.gridInputs.map { step in

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
    }

    private func reserveGridPoints_() {
        usableGridOffsets = Grid.moves.compactMap { offset in

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
}
