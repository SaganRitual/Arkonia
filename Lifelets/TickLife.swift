import CoreGraphics
import Foundation

final class TickLife: Dispatchable {
    var isAlive = false
    var canSpawn = false
    var onComplete: ((Bool, Bool) -> Void)?

    static let dispatchQueue = DispatchQueue(
        label: "ak.ticklife.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    override func launch() {
        Debug.log(level: 167) { "TickLife \(six(scratch.stepper.name))" }
        Debug.debugColor(scratch.stepper, .yellow, .blue)

        tick()
    }

    private func tick() { Clock.dispatchQueue.async { self.tickLife(.clock) } }
}

extension TickLife {
    private func tickLife(_ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .clock)

        scratch.currentTime = Clock.shared!.worldClock
        scratch.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async { self.tickLife_(.tickLife) }
    }

    private func tickLife_(_ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .tickLife)

        let isAlive = scratch.stepper.metabolism.tickLifeMath(
            cNeurons: scratch.stepper.net!.cNeurons,
            co2Counter: scratch.stepper.dispatch.scratch.co2Counter,
            cOffspring: scratch.stepper.cOffspring
        )

        let canSpawn = scratch.stepper.canSpawn()

        Grid.arkonsPlaneQueue.async { self.routeLife(isAlive, canSpawn, .arkonsPlane) }
    }
}

extension TickLife {
    private func routeLife(_ isAlive: Bool, _ canSpawn: Bool, _ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .arkonsPlane)

        Debug.log(level: 167) { "routeLife \(six(scratch.stepper.name))" }

        precondition(Grid.shared.isOnGrid(scratch.stepper.gridCell.gridPosition))

        if !isAlive      { scratch.dispatch!.apoptosize()  }
        else if canSpawn { scratch.dispatch!.spawn()       }
        else             { scratch.dispatch!.computeMove() }
    }
}

extension Metabolism {
    func tickLifeMath(
        cNeurons: Int, co2Counter: CGFloat, cOffspring: Int
    ) -> Bool {
        // If we're getting bogged down so much that we can't get to this arkon
        // in less than our time limit, kill this guy off
        let currentTime = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        let duration = currentTime - mostRecentCycleStartTime

        defer {
            mostRecentCycleStartTime = currentTime
            overTimeLimitCount = 0
        }

        if mostRecentCycleStartTime > 0 {
            if duration > Arkonia.one_ms * UInt64(500) {
                overTimeLimitCount += 1

                if overTimeLimitCount > 5 || duration >= Arkonia.one_ms * UInt64(1000)  {
                    Debug.log(level: 173) { "Killing off someone after \(duration / UInt64(Arkonia.one_ms))ms" }
                    return false
                }
            }
        }

        mostRecentCycleStartTime = currentTime
        overTimeLimitCount = 0

        let joulesNeeded = Arkonia.fudgeMassFactor * mass + CGFloat(cNeurons) * Arkonia.neuronCostPerCycle

        withdrawFromReady(joulesNeeded)

        let oxygenCost: CGFloat = Arkonia.oxygenCostPerTick
        let co2Cost: CGFloat = pow(Arkonia.co2BaseCost, co2Counter)

        Debug.log(level: 96) { "O2 cost \(oxygenCost), CO2 cost \(co2Cost)" }

        oxygenLevel -= oxygenCost
        co2Level += co2Cost

        Debug.log(level: 96) { "O2 level \(oxygenLevel), CO2 level \(co2Level)" }

        return
            fungibleEnergyFullness > 0 &&
            oxygenLevel > 0 &&
            co2Level < Arkonia.co2MaxLevel
    }
}
