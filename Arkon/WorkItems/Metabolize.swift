import GameplayKit

final class Metabolize: Dispatchable {
   internal override func launch_() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        st.metabolism.metabolizeProper()
        dp.colorize()
    }
}

extension Metabolism {
    fileprivate func metabolizeProper() {
        let internalTransferRate = CGFloat(200)

        var export = !stomach.isEmpty && !readyEnergyReserves.isFull

        if export {
            let transfer = stomach.withdraw(25 * readyEnergyReserves.energyDensity)
            readyEnergyReserves.deposit(transfer)
        }

        export = readyEnergyReserves.isAmple && !fatReserves.isFull

        if export {
            let surplus_ = readyEnergyReserves.level - readyEnergyReserves.overflowThreshold
            let surplus = min(surplus_, internalTransferRate * fatReserves.energyDensity)
            let net = readyEnergyReserves.withdraw(surplus)
            fatReserves.deposit(net)
        }

        let `import` = readyEnergyReserves.level < reUnderflowThreshold

        if `import` {
            let refill = fatReserves.withdraw(internalTransferRate * fatReserves.energyDensity)
            readyEnergyReserves.deposit(refill)
        }

        export = fatReserves.isAmple && !spawnReserves.isFull

        if export {
            let transfer = fatReserves.withdraw(internalTransferRate * spawnReserves.energyDensity)
            spawnReserves.deposit(transfer)
        }
    }
}
