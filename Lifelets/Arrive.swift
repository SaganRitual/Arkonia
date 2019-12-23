import SpriteKit

final class Arrive: Dispatchable {
    internal override func launch() { arrive() }

    func arrive() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.debugColor(st, .green, .green)
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        precondition(shuttle.toCell != nil && shuttle.toCell?.sprite?.name == st.name)

        Log.L.write("Arrive: \(six(st.name))/\(six(shuttle.fromCell?.ownerName)) at \(st.gridCell.gridPosition)\(shuttle.fromCell?.gridPosition ?? AKPoint(x: -4242, y: -4242)) attacks \(six(shuttle.consumedSprite?.name))/\(six(shuttle.toCell?.ownerName)) at \(shuttle.toCell?.gridPosition ?? AKPoint(x: -4242, y: -4242))/\(shuttle.consumedSprite?.position ?? CGPoint(x: -4242, y: -4242))", level: 55)

        switch shuttle.consumedContents {
        case .arkon:
            dp.parasitize()

        case .manna:
            graze()

        default: fatalError()
        }
    }
}

extension Arrive {
    func graze() { GriddleScene.shared.run(SKAction.run { self.graze_() }) }

    func graze_() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }

        guard let sprite = shuttle.consumedSprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        let inhaleFudgeFactor: CGFloat = 2.0
        var harvested: CGFloat = 0

        func partA() { manna.harvest {
            harvested = $0
            partB() } }

        func partB() {
            st.metabolism.absorbEnergy(harvested)

            let toInhale = inhaleFudgeFactor * harvested / Manna.maxEnergyContentInJoules
            st.metabolism.inhale(toInhale)
            Log.L.write("absorb (\(String(format:"%-2.6f", harvested))), inhale(\(String(format:"%-2.6f", toInhale)))", level: 67)

            Manna.populator.beEaten(sprite)

            precondition(
                (ch.cellShuttle?.fromCell != nil) &&
                (ch.cellShuttle?.toCell?.sprite?.getStepper(require: false) != nil)
            )

            dp.releaseStage()
        }

        ch.stillCounter = 0
        Log.L.write("reset still", level: 60)
        partA()
    }

}
