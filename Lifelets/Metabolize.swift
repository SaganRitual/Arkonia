import GameplayKit

final class Metabolize: Dispatchable {
    internal override func launch() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Metabolize \(six(st.name))", level: 71)

        if Debug.debugColorIsEnabled { st.sprite.color = .red }

        st.metabolism.metabolizeProper(ch.stillCounter > 0, st.nose)

        dp.colorize()
    }
}

extension Metabolism {
    fileprivate func metabolizeProper(_ isStarving: Bool, _ nose: SKSpriteNode) {
        if stomach.level > 0 {
            Debug.log("metabolizeProper; stomach = \(stomach.level) (\(stomach.level / stomach.capacity)) oxygen = \(oxygenLevel)", level: 89)
        }

        if fungibleEnergyFullness < 0.5 {
            if Debug.debugColorIsEnabled { nose.color = .green }
        } else {
            if Debug.debugColorIsEnabled { nose.color = .blue }
        }

        nose.colorBlendFactor = 1 - fungibleEnergyFullness

        var logMessage = "mp:"

        let stomachToReady = !stomach.isEmpty && !readyEnergyReserves.isFull
//        logMessage += " stomachToReady = \(stomachToReady), ready is full = \(readyEnergyReserves.isFull)"

        if stomachToReady {
            let transfer = stomach.withdraw(Arkonia.energyTransferRateInJoules)
            readyEnergyReserves.deposit(transfer)
            logMessage += ", transfer \(transfer) stomach->ready"
        }

        let readyToFat = readyEnergyReserves.isAmple && !fatReserves.isFull
//        logMessage += ", readyToFat = \(readyToFat)"

        if readyToFat {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, Arkonia.energyTransferRateInJoules)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
            logMessage += ", \(net) ready->fat"
        }

        let tapFatReserves = (readyEnergyReserves.level < reUnderflowThreshold)
//        logMessage += ", tapFatReserves = \(tapFatReserves)"

        if tapFatReserves {
            let refill = fatReserves.withdraw(Arkonia.energyTransferRateInJoules)
            readyEnergyReserves.deposit(refill)
            logMessage += ", \(refill) fat->ready"
        }

        let fatToSpawn = fatReserves.isAmple && !spawnReserves.isFull

        if fatToSpawn {
            let transfer = fatReserves.withdraw(Arkonia.energyTransferRateInJoules)
            spawnReserves.deposit(transfer)
            logMessage += ", \(transfer) fat->spawn"
        }

        if logMessage.count > 3 {
            Debug.log(logMessage, level: 89)
        }
    }
}
