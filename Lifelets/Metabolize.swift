import GameplayKit

final class Metabolize: Dispatchable {
    internal override func launch() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        Debug.log(level: 71) { "Metabolize \(six(scratch.stepper.name))" }

        if Arkonia.debugColorIsEnabled { scratch.stepper.sprite.color = .red }

        scratch.stepper.metabolism.metabolizeProper(scratch.co2Counter > 0, scratch.stepper.nose)

        scratch.dispatch!.colorize()
    }
}

extension Metabolism {
    fileprivate func metabolizeProper(_ isStarving: Bool, _ nose: SKSpriteNode) {
//        nose.color = .green
        nose.colorBlendFactor = min(fungibleEnergyFullness * 2, 1)

        let stomachToReady = !stomach.isEmpty && !readyEnergyReserves.isFull

        if stomachToReady {
            let transfer = stomach.withdraw(Arkonia.energyTransferRateInJoules)
            readyEnergyReserves.deposit(transfer)
        }

        let readyToFat = readyEnergyReserves.isAmple && !fatReserves.isFull

        if readyToFat {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, Arkonia.energyTransferRateInJoules)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
        }

        let tapFatReserves = (readyEnergyReserves.level < reUnderflowThreshold)

        if tapFatReserves {
            let refill = fatReserves.withdraw(Arkonia.energyTransferRateInJoules)
            readyEnergyReserves.deposit(refill)
        }

        let fatToSpawn = fatReserves.isAmple && !spawnReserves.isFull

        if fatToSpawn {
            let transfer = fatReserves.withdraw(Arkonia.energyTransferRateInJoules)

            // Chronic hunger makes it difficult to have more babies, so eat up
            let adjusted = transfer * (1 - hunger / 2)

            spawnReserves.deposit(adjusted)
        }
    }
}
