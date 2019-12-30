import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        Log.L.write("Arrive \(six(st.name))", level: 71)

        switch shuttle.consumedContents {
        case .arkon: dp.parasitize()
        case .manna: graze()
        default: fatalError()
        }
    }

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        guard let sprite = shuttle.consumedSprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        ch.stillCounter = 0

        WorkItems.graze(st, manna) {
            Manna.populator.beEaten(sprite)
            dp.releaseStage()
        }
    }
}

extension WorkItems {

    static func graze(_ stepper: Stepper, _ manna: Manna, _ onComplete: @escaping () -> Void) {
        WorkItems.harvest(manna) { harvested in
            stepper.metabolism.absorbEnergy(harvested)

            let toInhale = Arkonia.inhaleFudgeFactor * harvested / Manna.maxEnergyContentInJoules
            stepper.metabolism.inhale(toInhale)

            Manna.populator.beEaten(manna.sprite)
            onComplete()
        }
    }

    static func getEnergyContentInJoules(
        _ manna: Manna, _ onComplete: @escaping Clock.OnComplete1CGFloatp
    ) {
        Clock.dispatchQueue.async {
            let entropy = Clock.shared.getEntropy()
            let energyContent = manna.getEnergyContentInJoules(entropy)
            onComplete(energyContent)
        }
    }

    static func harvest(_ manna: Manna, _ onComplete: @escaping Clock.OnComplete1CGFloatp) {
        WorkItems.getEnergyContentInJoules(manna) { net in
            manna.harvest()
            onComplete(net)
        }
    }

}
