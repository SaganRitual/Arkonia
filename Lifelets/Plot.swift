import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?

    internal override func launch() { plot() }

    private func plot() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 104) { "Plot \(six(st.name))" }

        var entropy: CGFloat = 0

        func a() { self.computeMove(b) }
        func b() { Funge.dispatchQueue.async(execute: c) }
        func c() { ch.co2Counter += ch.cellShuttle!.didMove ? 0 : 1; d() }
        func d() { dp.moveSprite() }

        a()
    }

    func getSenseData(_ gridInputs: [Double]) {
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial
    }

    func computeMove(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        var gridInputs = [Double]()

        func a() { loadGridInputs(from: sg) { gridInputs = $0; b() } }

        func b() { Net.dispatchQueue.async(execute: c) }

        func c() {
            self.getSenseData(gridInputs)
            Debug.log(level: 103) { "gridInputs \(gridInputs)" }
            guard let sd = self.senseData else { fatalError() }
            self.makeCellShuttle(sd, sg) { ch.cellShuttle = $0; d()  }
        }

        func d() { Grid.serialQueue.async(execute: e) }

        func e() {
            sg.releaseNonStageCells(keep: ch.cellShuttle!.toCell!)
            ch.engagerKey = nil
            Debug.log(level: 104) {
                "computeMove \(six(ch.name)) ->"
                + " \(ch.cellShuttle!.toCell?.contents ?? .invalid) to"
                + " \(ch.cellShuttle!.toCell?.gridPosition ?? AKPoint.zero),"
                + " \(ch.cellShuttle!.fromCell?.contents ?? .invalid) from"
                + " \(ch.cellShuttle!.fromCell?.gridPosition ?? AKPoint.zero)"
            }
            onComplete()
        }

        a()
    }
}

extension Plot {
    private func loadGridInputs(
        from senseGrid: CellSenseGrid, _ onComplete: @escaping ([Double]) -> Void
    ) {
        var entropyPerJoule = 0.0
        func a() { Clock.shared.entropize(1) { entropyPerJoule = Double($0); b() } }

        func b() { Grid.serialQueue.async(execute: c) }

        func c() {
            var gridInputs = [Double]()
            for ix in 0..<senseGrid.cells.count {
                let nutrition = self.loadGridInput(senseGrid.cells[ix])
                let nn = nutrition * entropyPerJoule
                gridInputs.append(nn)
            }

            onComplete(gridInputs)
        }

        a()
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> Double {

        if cellKey.contents == .invalid {
            return 0
        }

        switch cellKey.contents {
        case .arkon:
            return 0

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            let energy = manna.getEnergyContentInJoules()
            let nutrition = Double(energy) / Double(Arkonia.maxMannaEnergyContentInJoules)
            Debug.log(level: 139) { "nutrition \(nutrition) at \(cellKey.gridPosition)" }
            return nutrition

        case .nothing:
            return 0

        case .invalid: fatalError()
        }
    }

    private func getNonSpatialSenseData() -> [Double] {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var theData = [Double]()

        theData.append(contentsOf: [
            Double(st.gridCell.scenePosition.x / GriddleScene.arkonsPortal.size.width),
            Double(st.gridCell.scenePosition.y / GriddleScene.arkonsPortal.size.height)
        ])

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(st.metabolism.co2Level / Arkonia.co2MaxLevel)
        theData.append(contentsOf: [hunger, asphyxia])

        var fertileSpotData = [(Double, Double)]()
        for fertileSpot in MannaCannon.shared!.fertileSpots {
            let result = st.sprite.position - fertileSpot.node.position
            let theta = (result.x == 0) ? 0 : atan(result.y / result.x) / (CGFloat.pi / 2)
            let r = result.hypotenuse / GriddleScene.arkonsPortal.size.hypotenuse
            fertileSpotData.append((Double(r), Double(theta)))
        }

        fertileSpotData.sorted(by: { lhs, rhs in lhs.0 < rhs.0 }).forEach { pair in
            let r = pair.0, theta = pair.1
            assert(theta >= -1 && theta <= 1)
            theData.append(contentsOf: [r, theta])
        }

        Debug.log(level: 139) { "theData = \(theData)" }
        return theData
    }
}
