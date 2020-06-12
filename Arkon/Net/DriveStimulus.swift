import Foundation

struct DriveStimulus {
    weak var stepper: Stepper?

    init(_ stepper: Stepper) { self.stepper = stepper }

    func driveStimulus(_ onComplete: @escaping () -> Void) {
        Seasons.shared.getSeasonalFactors { self.driveStimulus_B($0, $1, onComplete) }
    }
}

private extension DriveStimulus {
    func driveStimulus_B(
        _ dayFullness: CGFloat, _ yearFullness: CGFloat,
        _ onComplete: @escaping () -> Void
    ) {
        transferSensorPadToSenseNeurons()
        transferNonPadInputsToSenseNeurons(dayFullness, yearFullness)
        onComplete()
    }

    func getNutrition(in cell: IngridCell) -> Float? {
        guard let stepper = Ingrid.shared.arkons.arkonAt(cell.absoluteIndex) else
            { return Ingrid.shared.manna.getNutrition(in: cell) }

        return Float(stepper.metabolism.energy.level)
    }

    func loadSelector(from cell: IngridCell) -> Float {
        return Ingrid.shared.getContents(in: cell).asSenseData()
    }

    func transferNonPadInputsToSenseNeurons(
        _ dayFullness: CGFloat, _ yearFullness: CGFloat
    ) {
        let st = stepper!, mt = st.metabolism!, cs = mt.spawn
        let ax = st.ingridCellAbsoluteIndex, gc = Ingrid.shared.cellAt(ax)

        // Average fullness of the spawn embryo; not really very representative,
        // see whether it has any effect.
        let ff = cs?.fatStore?.fullness ?? 0
        let hf = cs?.hamStore.fullness ?? 0
        let of = cs?.oxygenStore.fullness ?? 0
        let gestationFullness = (ff + hf + of) / 3.0

        let cGridSenseInputs = st.net.netStructure.cSenseNeuronsGrid

        func setMiscSense(_ sense: MiscSenses, _ value: CGFloat) {
            st.net.pSenseNeuronsMisc[sense.rawValue] = Float(value)
        }

        let hw = CGFloat(Ingrid.shared.core.gridDimensionsCells.width / 2)
        let hh = CGFloat(Ingrid.shared.core.gridDimensionsCells.height / 2)

        setMiscSense(.x, CGFloat(gc.gridPosition.x) / hw)
        setMiscSense(.y, CGFloat(gc.gridPosition.y) / hh)
        setMiscSense(.hunger, mt.hunger)
        setMiscSense(.asphyxiation, mt.asphyxiation)
        setMiscSense(.gestationFullness, gestationFullness)
        setMiscSense(.dayFullness, dayFullness)
        setMiscSense(.yearFullness, yearFullness)

        for (ss, pollenator) in zip(0..., MannaCannon.shared!.pollenators) {
            let diff = stepper!.sprite.position - pollenator.node.position

            let t = (diff.x == 0) ? 0 : atan(Float(diff.y) / Float(diff.x))
            let tt = t / (Float.pi / 2)

            let pn = stepper!.net.pSenseNeuronsPollenators
            let dh = diff.hypotenuse
            let ph = Ingrid.shared.core.portalDimensionsPix.hypotenuse

            pn[ss * 2 + 0] = Float(dh / ph)
            pn[ss * 2 + 1] = tt
        }
    }

    func transferSensorPadToSenseNeurons() {
        let sensorPad = stepper!.sensorPad
        let senseNeurons = UnsafeMutablePointer(mutating: stepper!.net.pNeurons)
        let cCells = stepper!.net.netStructure.cCellsWithinSenseRange

        senseNeurons.initialize(to: 0)

        // Skip my center cell; I don't need to know my nutritional value or
        // that I'm an arkon
        for ss in 1..<cCells {
            guard let cell = sensorPad[ss].cell else { continue }

            Debug.log(level: 195) { "getNutrition for \(stepper!.name) from local \(ss) \(sensorPad[ss].absoluteIndex)" }

            senseNeurons[2 * ss + 0] = getNutrition(in: cell) ?? 0
            senseNeurons[2 * ss + 1] = loadSelector(from: cell)
        }
    }
}
