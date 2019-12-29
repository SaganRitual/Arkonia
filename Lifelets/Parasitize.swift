import SpriteKit

final class Parasitize: Dispatchable {
    internal override func launch() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.writeDebug("Parasitize \(six(st.name))", scratch: ch)

        let result = attack()

        let bleedToDeath = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.5)
        let resizeToDeath = SKAction.scale(to: 0.25, duration: 0.5)
        let groupDo = SKAction.group([bleedToDeath, resizeToDeath])
        let groupUndo = SKAction.group([bleedToDeath.reversed(), resizeToDeath.reversed()])
        let sequence = SKAction.sequence([groupDo, groupUndo])
        let makeAScene = SKAction.repeat(sequence, count: 5)
        Debug.debugColor(result.1, .red, .yellow)
        Debug.debugColor(result.0, .green, .red)
        result.1.sprite.run(makeAScene) {
            Grid.shared.serialQueue.async { self.parasitize(result.0, result.1) }
        }
    }
}

extension Parasitize {
    func attack() -> (Stepper, Stepper) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        precondition(
            (ch.cellShuttle?.toCell != nil && ch.cellShuttle?.toCell?.sprite?.name == st.name && ch.engagerKey == nil) ||
                (ch.engagerKey?.sprite?.name == st.name && ch.cellShuttle?.toCell == nil)
        )

        (st.sprite.color, st.nose.color) = (.green, .blue)

        guard let (myScratch, _, myStepper) = scratch?.getKeypoints() else { fatalError() }

        guard let hisSprite = myScratch.cellShuttle?.consumedSprite else { fatalError() }
        guard let hisStepper = hisSprite.getStepper() else { fatalError() }

        Log.L.write("Parasitize: \(six(myStepper.name))/\(six(hisStepper.name)) attacks \(six(myScratch.cellShuttle?.consumedSprite?.name))", level: 56)

        let myMass = myStepper.metabolism.mass
        let hisMass = hisStepper.metabolism.mass

        Log.L.write("Parasitize: \(six(myStepper.name)) at \(myStepper.gridCell.gridPosition) attacks \(six(hisStepper.name)) at \(hisStepper.gridCell.gridPosition)", level: 56)

        if myMass > (hisMass * 1.25) {
            myStepper.isTurnabouted = false
            hisStepper.isTurnabouted = false

            precondition((hisStepper.dispatch.scratch.engagerKey as? HotKey) == nil)
            precondition(hisStepper.dispatch.scratch.cellShuttle == nil)

            Log.L.write("Parasitize2: \(six(myStepper.name)) eats \(six(hisStepper.name))", level: 56)
            myStepper.gridCell.descheduleIf(hisStepper)

            return (myStepper, hisStepper)
        } else {
            myStepper.isTurnabouted = true
            hisStepper.isTurnabouted = true

            Log.L.write("Parasitize3: \(six(hisStepper.name)) at \(hisStepper.gridCell.gridPosition) eats \(six(myStepper.name)) at \(myStepper.gridCell.gridPosition)", level: 56)

            let hisScratch = hisStepper.dispatch.scratch
            guard let myShuttle = myScratch.cellShuttle else { fatalError() }

            precondition((hisScratch.engagerKey is HotKey) == false)
            precondition(hisScratch.cellShuttle == nil)
            precondition(myShuttle.toCell != nil && myShuttle.fromCell != nil)

            hisScratch.cellShuttle = myShuttle.transferKeys(to: hisStepper)
            hisScratch.engagerKey = nil
            myScratch.cellShuttle = nil

            myStepper.gridCell.descheduleIf(hisStepper)

            return (hisStepper, myStepper)
        }
    }

    func parasitize(_ victor: Stepper, _ victim: Stepper) {
        victor.dispatch.scratch.stillCounter = 0
        victor.metabolism.parasitizeProper(victim)
        victor.dispatch.releaseStage()

        if victor.isTurnabouted {
            precondition(victim.sprite.name == victim.name)
            Log.L.write("victor isTurnabouted, stepper(\(six(victim.sprite.name))), stepper(\(six(victim.sprite.name)))", level: 66)
            victim.dispatch.apoptosize()
        }
    }
}

extension Metabolism {
    func parasitizeProper(_ victim: Stepper) {
        let spareCapacity = stomach.capacity - stomach.level
        let victimEnergy = victim.metabolism.withdrawFromReady(spareCapacity)
        let netEnergy = victimEnergy * 0.25

        absorbEnergy(netEnergy)
        inhale()
    }
}
