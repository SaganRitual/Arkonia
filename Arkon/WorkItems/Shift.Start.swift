import Foundation

class Shift {
    var sensoryInputs = [(Double, Double)]()
    var shifting = false
    var shifting2 = false
    weak var stepper: Stepper?
    var usableGridOffsets = [AKPoint]()

    init(stepper: Stepper) { self.stepper = stepper }

    deinit {
//        print("~Shift")
    }
}

extension Shift {
    func start(_ gridlet: Gridlet, completion: @escaping CoordinatorCallback) {
        let workItem = { [weak self] in
            defer { self?.shifting = false }
            self?.shifting = true
            self?.start_(gridlet)
        }

        Lockable<Void>().lock(workItem, completion)
    }

    private func start_(_ gridlet: Gridlet) {
        reserveGridPoints(gridlet)
        loadGridInputs(gridlet)
    }

    private func loadGridInputs(_ gridlet: Gridlet) {
        sensoryInputs = Stepper.gridInputs.map { step in

            let inputGridlet = step + gridlet.gridPosition

            if Gridlet.isOnGrid(inputGridlet.x, inputGridlet.y) {
//                print("loadGridInputs.isOnGrid = true", inputGridlet)
                let targetGridlet = Gridlet.at(inputGridlet)

                let contents = Gridlet.at(inputGridlet).contents
                let rvContents = contents.rawValue
                let nutrition: Double
                switch contents {
                case .arkon:
                    nutrition = Double(targetGridlet.sprite?.optionalStepper?.metabolism.energyFullness ?? 0)

                case .manna:
                    nutrition = Double(targetGridlet.sprite?.manna.energyContentInJoules ?? 0)

                case .nothing:
                    nutrition = 0
                }

                return (rvContents, nutrition)
            } else {
//                print("loadGridInputs.isOnGrid = false", inputGridlet)
            }

            return (Gridlet.Contents.nothing.rawValue, -1e6)
        }
    }

    private func reserveGridPoints(_ gridlet: Gridlet) {
//        print("reserveGridPoints(\(gridlet.gridPosition))")
        usableGridOffsets = Stepper.moves.compactMap { offset in

            let targetGridPoint = gridlet.gridPosition + offset
            if Gridlet.isOnGrid(targetGridPoint.x, targetGridPoint.y) {
//                print("reserveGridPoints.isOnGrid = true", targetGridPoint)
                let targetGridlet = Gridlet.at(targetGridPoint)

//                print("targetGridlet = \(targetGridlet.gridPosition) - ", terminator: "")
                if targetGridlet.gridletIsEngaged {
//                    print("already engaged")
                    return nil
                }
//                print("available - ", terminator: "")

                // If there's no arkon in our target cell, then we
                // can go there if we want
                if targetGridlet.contents != .arkon {
//                    print("set")
                    targetGridlet.gridletIsEngaged = true
                    return offset
                }

//                print("contains arkon - ")

                guard let intendedVictim = targetGridlet.sprite?.stepper else { fatalError() }

                if !intendedVictim.isAlive {
//                    print("dead already")
                    return nil }

//                print("live - ", terminator: "")
                // Not sure about this one; seems like it wouldn't be good for
                // us to be mussing about with other arkons while actions are
                // running?
                assert(Display.displayCycle != .actions)
                if Display.displayCycle == .actions { return nil }

                defer {
                    intendedVictim.stepperIsEngaged = true
                    targetGridlet.gridletIsEngaged = true
                }

                // If there's an arkon in our target cell that isn't engaged,
                // we can go attack it if we want
                if !intendedVictim.stepperIsEngaged {
//                    print("set")
                    return offset }
            }

//            print("reserveGridPoints.isOnGrid = false", targetGridPoint)
//            print("umm, already engaged?")
            return nil
        }
    }
}
