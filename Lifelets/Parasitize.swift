import SpriteKit

final class Parasitize: Dispatchable {

    internal override func launch() { WorkItems.parasitize(scratch) }
}

extension WorkItems {
    static func parasitize(_ scratch: Scratchpad?) {
        guard let (attackerScratch, _, attackerStepper) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Parasitize; attacker is \(six(attackerStepper.name))", level: 71)

        var victor: Stepper?, victim: Stepper?

        func a() { attack(by: attackerScratch) { (victor, victim) = ($0, $1); b() } }

        func b() {
            guard let winner = victor, let loser = victim else { fatalError() }

            Debug.debugColor(loser, .red, .yellow)
            Debug.debugColor(winner, .green, .red)

            dieHorribly(loser.sprite, c)
        }

        func c() {
            guard let winner = victor, let loser = victim else { fatalError() }
            parasitize(winner, loser)
        }

        a()
    }
}

extension WorkItems {
    private static let bleedToDeath = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.5)
    private static let resizeToDeath = SKAction.scale(to: 0.25, duration: 0.5)
    private static let groupDo = SKAction.group([bleedToDeath, resizeToDeath])
    private static let groupUndo = SKAction.group([bleedToDeath.reversed(), resizeToDeath.reversed()])
    private static let sequence = SKAction.sequence([groupDo, groupUndo])
    private static let makeAScene = SKAction.repeat(sequence, count: 5)

    static func dieHorribly(_ sprite: SKSpriteNode, _ onComplete: @escaping () -> Void) {
        sprite.run(makeAScene, completion: onComplete)
    }
}

extension WorkItems {
    static func attack(by scratch: Scratchpad, _ onComplete: @escaping (Stepper, Stepper) -> Void) {
        Substrate.serialQueue.async {
            let result = attack(scratch: scratch)
            onComplete(result.0, result.1)
        }
    }

    private static func attack(scratch: Scratchpad?) -> (Stepper, Stepper) {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        Debug.debugColor(st, .green, .blue)

        guard let (myScratch, _, myStepper) = scratch?.getKeypoints() else { fatalError() }

        guard let hisSprite = myScratch.cellShuttle?.consumedSprite else { fatalError() }
        guard let hisStepper = hisSprite.getStepper() else { fatalError() }

        let myMass = myStepper.metabolism.mass
        let hisMass = hisStepper.metabolism.mass

        if myMass > (hisMass * 1.25) {
            myStepper.isTurnabouted = false
            hisStepper.isTurnabouted = false

            myStepper.gridCell.descheduleIf(hisStepper)

            return (myStepper, hisStepper)
        } else {
            myStepper.isTurnabouted = true
            hisStepper.isTurnabouted = true

            let hisScratch = hisStepper.dispatch.scratch
            guard let myShuttle = myScratch.cellShuttle else { fatalError() }

            hisScratch.cellShuttle = myShuttle.transferKeys(to: hisStepper)
            hisScratch.engagerKey = nil
            myScratch.cellShuttle = nil

            myStepper.gridCell.descheduleIf(hisStepper)

            return (hisStepper, myStepper)
        }
    }

    static func parasitize(_ victor: Stepper, _ victim: Stepper) {
        Substrate.serialQueue.async {
            victor.dispatch.scratch.stillCounter = 0
            victor.metabolism.parasitizeProper(victim)
            victor.dispatch.releaseStage()

            if victor.isTurnabouted { victim.dispatch.apoptosize() }
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
