import Foundation

extension Shift {
    func loadGridInputs() {
        sensoryInputs = (0..<ArkoniaCentral.cSenseGridlets).map { index in
            let gridPoint = stepper.getGridPointByIndex(index)
            return self.loadGridInput_(gridPoint)
        }
    }

    func reserveGridPoints() {
        assert(runType == .barrier)

        engagedGridlets = (0..<ArkoniaCentral.cMotorGridlets).compactMap { index in
            let gridPoint = stepper.getGridPointByIndex(index, absolute: false)
            guard let gridlet = Gridlet.atIf(gridPoint) else { return nil }

            return gridlet.engage(require: false)
        }
    }
}

extension Shift {

    func loadGridInput_(_ step: AKPoint) -> (Double, Double) {
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
        assert(runType == .barrier)
        let tp = stepper.gridlet.gridPosition + offset

        guard let targetGridlet = Gridlet.atIf(tp.x, tp.y) else { return nil }

        if targetGridlet.gridletIsEngaged { return nil }

        targetGridlet.gridletIsEngaged = true
        return targetGridlet
    }
}
