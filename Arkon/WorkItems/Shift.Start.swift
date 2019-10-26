import Foundation

extension Stepper {
    func shiftStart() {
        World.lock( { [unowned self] () -> [Void]? in
//            print("shiftStart \(self.name)")
            self.shifter = Shifter(stepper: self)
            return nil
        }, { ([Void]?) -> Void in
//            print("shifter.start")
            self.shifter!.start(self.gridlet)
        },
            .concurrent
        )
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

//            print("shift start \(gridlet.scenePosition)")
            self.start_()
            return nil

        }, { [unowned self] (_ nothing: [Void]?) -> Void in
//            print("csin")
            self.stepper.calculateShift()
//            print("csout")
        },
           .concurrent
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
//            print("1 \(stepper.name)")

            let targetGridPoint = stepper.gridlet.gridPosition + offset
//            print("rgp \(stepper.gridlet.gridPosition) + \(offset) = \(targetGridPoint)")

            if Gridlet.isOnGrid(targetGridPoint.x, targetGridPoint.y) {
//                print("2 \(stepper.name)")
                let targetGridlet = Gridlet.at(targetGridPoint)
//                print("tg \(targetGridlet.scenePosition)")

                if !targetGridlet.gridletIsEngaged {
//                    print("3 \(stepper.name)")
                    targetGridlet.gridletIsEngaged = true
                    return offset
                } else {
//                    print("4 \(stepper.name)")
                }
            } else {
//                print("5 \(stepper.name)")
            }

            return nil
        }

//        print("ugo", stepper.name, usableGridOffsets)
    }
}
