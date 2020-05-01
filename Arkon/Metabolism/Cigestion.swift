import Foundation

extension Metabolism {
    func absorb(_ nutrition: Manna.Nutrition?) {
        guard let n = nutrition else { return }

        stomach.deposit(n.ham)
        lungs.deposit(n.oxygen)

        zip(
            [n.bone, n.leather, n.poison],
            [self.bone, self.leather, self.poison]
        ).forEach {
            $0.1.depositVitamins($0.0)
        }

        report("absorb")
    }

    func digest() {

        report("dig000")
        let stomachToReady = !stomach.isEmpty && !ready.isFull

        if stomachToReady {
            let readyAvailableCapacityKg = ready.availableCapacity * EnergyBudget.Ready.densityKgPerJoule
            let netHamKg = stomach.withdraw(readyAvailableCapacityKg)
            if netHamKg > 0 {
                let readyHamJoules = netHamKg / EnergyBudget.Ready.densityKgPerJoule
                ready.deposit(readyHamJoules)
            }

            report("dig001")
        }

//        for receiver: Deployable in [bone, leather, poison] {
//            if receiver.isFull { continue }
//
//            let requestJoules = receiver.energyDensity * (receiver.capacity - receiver.level)
//            let cJoules = withdrawFromReadySurplus(requestJoules)
//            if cJoules > 0 { receiver.deposit(cJoules) }
//        }

        let readyToFat = ready.isOverflowing && !fat.isFull

        if readyToFat {
            let fatAvailableCapacityJoules = fat.availableCapacity / EnergyBudget.Fat.densityKgPerJoule
            let netEnergy = withdrawFromReadySurplus(fatAvailableCapacityJoules)
            if netEnergy > 0 { fat.deposit(netEnergy) }

            report("dig002")
        }

        let fatToReady = ready.isUnderflowing && !fat.isEmpty

        if fatToReady {
            let readyAvailableCapacityKg = ready.availableCapacity * EnergyBudget.Ready.densityKgPerJoule
            let netFatKg = fat.withdraw(readyAvailableCapacityKg)
            if netFatKg > 0 {
                let readyFatJoules = netFatKg / EnergyBudget.Ready.densityKgPerJoule
                ready.deposit(readyFatJoules)
            }

            report("dig003")
        }

        let fatToSpawn = fat.isOverflowing && !spawn.isFull

        if fatToSpawn {
            let netFatKg = fat.withdraw(spawn.availableCapacity)
            if netFatKg > 0 { spawn.deposit(netFatKg) }
        }

        report("dig004")
    }

    func inhale(CCs: CGFloat) { lungs.inhale(CCs); report("inhale") }
}
