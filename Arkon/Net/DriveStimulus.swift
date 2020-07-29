import Foundation

struct DriveStimulus {
    enum MiscSenses: Int, CaseIterable {
        case x, y, hunger, asphyxiation
        case gestationFullness, dayFullness, yearFullness
    }

    unowned let stepper: Stepper

    init(_ stepper: Stepper) { self.stepper = stepper }

    func driveStimulus(_ onComplete: @escaping () -> Void) {
        Clock.dispatchQueue.async {
            let sh = Clock.shared.seasonalFactors.diurnalCurve
            let ssh = Clock.shared.seasonalFactors.seasonalCurve

            mainDispatch { self.driveStimulus_B(sh, ssh, onComplete) }
        }
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

    // Average fullness of the sporangium; not really very representative,
    // see whether it has any effect.
    func getGestationFullness(_ sporangium: ChamberedStore?) -> CGFloat {
        guard let ng = sporangium else { return 0 }

        let sf = [
            (ng.fatStore?.fullness ?? 0), ng.hamStore.fullness, ng.oxygenStore.fullness
        ]

        return sf.reduce(0, +) / CGFloat(sf.count)
    }

    func transferNonPadInputsToSenseNeurons(
        _ dayFullness: CGFloat, _ yearFullness: CGFloat
    ) {
        let st = stepper, mt = st.metabolism, sn = st.spindle

        let gp = Grid.gridPosition(of: sn.gridCell.properties.gridAbsoluteIndex)
        let gestationFullness = getGestationFullness(mt.sporangium)

        func setMiscSense(_ sense: MiscSenses, _ value: CGFloat) {
            st.net.pSenseNeuronsMisc[sense.rawValue] = Float(value)
        }

        let hw = CGFloat(Grid.gridDimensionsCells.width / 2)
        let hh = CGFloat(Grid.gridDimensionsCells.height / 2)

        setMiscSense(.x, CGFloat(gp.x) / hw)
        setMiscSense(.y, CGFloat(gp.y) / hh)
        setMiscSense(.hunger, mt.hunger)
        setMiscSense(.asphyxiation, mt.asphyxiation)
        setMiscSense(.gestationFullness, gestationFullness)
        setMiscSense(.dayFullness, dayFullness)
        setMiscSense(.yearFullness, yearFullness)

        for (ss, pollenator) in zip(0..., MannaCannon.shared.pollenators) {
            let diff = stepper.thorax.position - pollenator.node.position

            let t = (diff.x == 0) ? 0 : atan(Float(diff.y) / Float(diff.x))
            let tt = t / (Float.pi / 2)

            let pn = stepper.net.pSenseNeuronsPollenators
            let dh = diff.hypotenuse
            let ph = Grid.portalDimensionsPix.hypotenuse

            pn[ss * 2 + 0] = Float(dh / ph)
            pn[ss * 2 + 1] = tt
        }
    }

    func transferSensorPadToSenseNeurons() {
        let sensorPad = stepper.sensorPad
        let senseNeurons = UnsafeMutablePointer(mutating: stepper.net.pNeurons)
        let cCells = stepper.net.netStructure.sensorPadCCells

        senseNeurons.initialize(to: 0)

        for ss in 1..<cCells {
            senseNeurons[2 * ss + 0] = sensorPad.getNutrition(at: ss)
            senseNeurons[2 * ss + 1] = sensorPad.loadSelector(at: ss)
        }
    }
}
