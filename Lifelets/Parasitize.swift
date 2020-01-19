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

            Debug.debugColor(loser, .red, .purple)
            Debug.debugColor(winner, .green, .red)

            dieHorribly(loser.sprite, c)
        }

        func c() {
            guard let winner = victor, let loser = victim else { fatalError() }
            parasitize(winner, loser, d)
        }

        func d() {
            guard let winner = victor else { fatalError() }
            winner.dispatch.scratch.co2Counter = 0
        }

        a()
    }
}

extension WorkItems {
    private static let big = Arkonia.arkonScaleFactor * 3 / Arkonia.zoomFactor
    private static let small = Arkonia.arkonScaleFactor / Arkonia.zoomFactor
    private static let d = 0.1

    private static let bleedToDeath = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: d)
//    private static let resizeToDeath = SKAction.scale(to: big, duration: d)
    private static let deelbToDeath = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: d)
//    private static let eziserToDeath = SKAction.scale(to: small, duration: d)
//    private static let groupDo = SKAction.group([bleedToDeath, resizeToDeath])
//    private static let groupUndo = SKAction.group([deelbToDeath, eziserToDeath])
    private static let sequence = SKAction.sequence([bleedToDeath, deelbToDeath])
    private static let makeAScene = SKAction.repeat(sequence, count: 5)

    static func dieHorribly(_ sprite: SKSpriteNode, _ onComplete: @escaping () -> Void) {
        sprite.run(makeAScene, completion: onComplete)
    }
}

extension WorkItems {
    static func attack(by scratch: Scratchpad, _ onComplete: @escaping (Stepper, Stepper) -> Void) {
        Substrate.serialQueue.async {
            attack(scratch: scratch) { victor, victim in onComplete(victor, victim) }
        }
    }

    private static func attack(scratch: Scratchpad?, _ onComplete: @escaping (Stepper, Stepper) -> Void) {
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

            onComplete(myStepper, hisStepper)
        } else {
            myStepper.isTurnabouted = true
            hisStepper.isTurnabouted = true

            let hisScratch = hisStepper.dispatch.scratch
            guard let myShuttle = myScratch.cellShuttle else { fatalError() }

            myShuttle.transferKeys(to: hisStepper) {
                hisScratch.cellShuttle = $0
                hisScratch.engagerKey = nil
                myScratch.cellShuttle = nil

                myStepper.gridCell.descheduleIf(hisStepper)

                onComplete(hisStepper, myStepper)
            }
        }
    }

    static func parasitize(
        _ victor: Stepper, _ victim: Stepper, _ onComplete: @escaping () -> Void
    ) {
        Substrate.serialQueue.async {
            victor.metabolism.parasitizeProper(victim)
            victor.dispatch.releaseStage()

            victim.dispatch.apoptosize()

            onComplete()
        }
    }
}

extension Metabolism {
    func parasitizeProper(_ victim: Stepper) {
        let spareCapacity = stomach.capacity - stomach.level
        let victimEnergy = victim.metabolism.withdrawFromReady(spareCapacity)
        let netEnergy = victimEnergy * 0.25

        absorbEnergy(netEnergy)
    }
}
