import GameplayKit

final class Metabolize: Dispatchable {
    internal override func launch() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        writeDebug("Metabolize \(six(st.name))", scratch: ch)
        if ArkoniaCentral.debugColorIsEnabled { st.sprite.color = .red }
        st.metabolism.metabolizeProper(ch.stillCounter > 0, st.nose)

        precondition(ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition
        )

        dp.colorize()
    }
}

extension Metabolism {
    fileprivate func metabolizeProper(_ isStarving: Bool, _ nose: SKSpriteNode) {
        let internalTransferRate = CGFloat(50)
        Log.L.write("metabolizeProper; stomach = \(stomach.level) (\(stomach.level / stomach.capacity)) oxygen = \(oxygenLevel)", level: 65)

        if fungibleEnergyFullness < 0.5 {
            if ArkoniaCentral.debugColorIsEnabled { nose.color = .green }
            nose.colorBlendFactor = 1 - fungibleEnergyFullness
        } else {
            if ArkoniaCentral.debugColorIsEnabled { nose.color = .blue }
            nose.colorBlendFactor = 1
        }

        var logMessage = ""

        let stomachToReady = !stomach.isEmpty && !readyEnergyReserves.isFull
        logMessage += ", stomachToReady = \(stomachToReady)"

        if stomachToReady {
            let transfer = stomach.withdraw(internalTransferRate * readyEnergyReserves.energyDensity)
            readyEnergyReserves.deposit(transfer)
            logMessage += ", transfer \(transfer)"
        }

        let readyToFat = readyEnergyReserves.isAmple && !fatReserves.isFull
        logMessage += ", readyToFat = \(readyToFat)"

        if readyToFat {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, internalTransferRate * fatReserves.energyDensity)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
            logMessage += ", net = \(net)"
        }

        let tapFatReserves = (readyEnergyReserves.level < reUnderflowThreshold)
        logMessage += ", tapFatReserves = \(tapFatReserves)"

        if tapFatReserves {
            let refill = fatReserves.withdraw(internalTransferRate * fatReserves.energyDensity)
            readyEnergyReserves.deposit(refill)
            logMessage += ", refill = \(refill)"
        }

        let fatToSpawn = fatReserves.isAmple && !spawnReserves.isFull
        logMessage += ", fatToSpawn = \(fatToSpawn)"

        if fatToSpawn {
            let transfer = fatReserves.withdraw(internalTransferRate * spawnReserves.energyDensity)
            spawnReserves.deposit(transfer)
            logMessage += ", transfer = \(transfer)"
        }

        Log.L.write(logMessage, level: 65)
    }
}
