import GameplayKit

final class Metabolize: Dispatchable {
   override func launch() {
       guard let w = wiLaunch else { fatalError() }
       World.shared.concurrentQueue.async(execute: w)
   }

    internal override func launch_() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        st.metabolism.metabolizeProper(ch.stillCounter > 0, st.sprite)
        dp.colorize()
    }
}

extension Metabolism {
    fileprivate func metabolizeProper(_ isStarving: Bool, _ nose: SKSpriteNode) {
        let internalTransferRate = CGFloat(50)
        Log.L.write("metabolizeProper; stomach = \(stomach.level) (\(stomach.level / stomach.capacity)) oxygen = \(oxygenLevel)", level: 45)

        if fungibleEnergyFullness < 0.5 {
            nose.color = .red
            nose.colorBlendFactor = 1 - fungibleEnergyFullness
        } else {
            nose.color = .white
            nose.colorBlendFactor = 1
        }

        let stomachToReady = !stomach.isEmpty && !readyEnergyReserves.isFull

        if stomachToReady {
            let transfer = stomach.withdraw(internalTransferRate * readyEnergyReserves.energyDensity)
            readyEnergyReserves.deposit(transfer)
        }

        let readyToFat = readyEnergyReserves.isAmple && !fatReserves.isFull

        if readyToFat {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, internalTransferRate * fatReserves.energyDensity)
            let net = readyEnergyReserves.withdraw(surplus)
            let preventCornerSwarms = net / (isStarving ? 3 : 1)
            fatReserves.deposit(preventCornerSwarms)
        }

        let tapFatReserves = (readyEnergyReserves.level < reUnderflowThreshold)
        let strainingTheSystem = isStarving || stomach.isEmpty

        if tapFatReserves || strainingTheSystem {
            let refill = fatReserves.withdraw(internalTransferRate * fatReserves.energyDensity)
            let entropyCost: CGFloat = 0.75
            let preventCornerSwarms = entropyCost * (strainingTheSystem ? (2 * fatReserves.energyDensity) : 1)
            readyEnergyReserves.deposit(refill * preventCornerSwarms)
        }

        let fatToSpawn = fatReserves.isAmple && !spawnReserves.isFull

        if fatToSpawn {
            let transfer = fatReserves.withdraw(internalTransferRate * spawnReserves.energyDensity)
            spawnReserves.deposit(transfer)
        }
    }
}
