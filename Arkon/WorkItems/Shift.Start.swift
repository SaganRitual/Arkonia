import Foundation

class Shift {
    var sensoryInputs = [(Double, Double)]()
    weak var stepper: Stepper?
    var usableGridOffsets = [AKPoint]()

    init(stepper: Stepper) { self.stepper = stepper }

    deinit {
//        print("~Shift")
    }
}

extension Shift {
    func start(_ gridlet: Gridlet, completion: @escaping Lockable<Void>.LockCompletion) {
        func workItem() { start_(gridlet) }
        Lockable<Void>().lock(workItem, completion)
    }

    private func start_(_ gridlet: Gridlet) {
        reserveGridPoints(gridlet)
        loadGridInputs(gridlet)
    }

    private func loadGridInputs(_ gridlet: Gridlet) {
        sensoryInputs = Stepper.gridInputs.map { step in

            let inputGridlet = step + gridlet.gridPosition
            if !Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
                return (Gridlet.Contents.nothing.rawValue, -1e6)
            }

            let targetGridlet = Gridlet.at(inputGridlet)

            let nutrition: Double

            switch targetGridlet.contents {
            case .arkon:
                nutrition = Double(targetGridlet.sprite?.optionalStepper?.metabolism.energyFullness ?? 0)

            case .manna:
                nutrition = Double(targetGridlet.sprite?.manna.energyContentInJoules ?? 0)

            case .nothing:
                nutrition = 0
            }

            return (targetGridlet.contents.rawValue, nutrition)
        }
    }

    private func reserveGridPoints(_ gridlet: Gridlet) {
        usableGridOffsets = Stepper.moves.compactMap { offset in

            let targetGridPoint = gridlet.gridPosition + offset

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
