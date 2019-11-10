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

//        print("sge1")
        self.gridletEngager = ge
    }
}

extension Shift {

    func loadGridInput_(_ gridletCopy: GridletCopy?) -> (Double, Double)? {
        guard let gc = gridletCopy else { return nil }

        if !Gridlet.isOnGrid(gc.gridPosition) { return nil }

        let nutrition: Double

        switch gc.contents {
        case .arkon:
            nutrition = Double(stepper.metabolism.energyFullness)

        case .manna:
            let sprite = gc.sprite!
            guard let manna = Manna.getManna(from: sprite) else { fatalError() }
            nutrition = Double(manna.energyContentInJoules)

        case .nothing:
            nutrition = 0
        }

        return (gc.contents.rawValue, nutrition)
    }
}
