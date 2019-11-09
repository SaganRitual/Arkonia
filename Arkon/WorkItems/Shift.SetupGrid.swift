import Foundation

extension Shift {
    func loadGridInputs() {
        sensoryInputs = gridletEngager.gridletCopies.map { gridletCopy in
            return self.loadGridInput_(gridletCopy)
        }
    }

    func reserveGridPoints() {
        assert(runType == .barrier)

        guard let ge = stepper.gridlet.engageBlock(
            of: ArkoniaCentral.cMotorGridlets, owner: stepper.name
        ) else { fatalError() }

        self.gridletEngager = ge
    }
}

extension Shift {

    func loadGridInput_(_ gridletCopy: GridletCopy) -> (Double, Double) {
        if !Gridlet.isOnGrid(gridletCopy.gridPosition) {
            return (Gridlet.Contents.nothing.rawValue, 0)
        }

        let targetGridlet = Gridlet.at(gridletCopy.gridPosition)

        let nutrition: Double

        switch targetGridlet.contents {
        case .arkon:
            nutrition = Double(stepper.metabolism.energyFullness)

        case .manna:
            let sprite = targetGridlet.sprite!
            guard let manna = Manna.getManna(from: sprite) else { fatalError() }
            nutrition = Double(manna.energyContentInJoules)

        case .nothing:
            nutrition = 0
        }

        return (targetGridlet.contents.rawValue, nutrition)
    }
}
