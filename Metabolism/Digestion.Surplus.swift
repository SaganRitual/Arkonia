import Foundation

extension Metabolism {
    func backfillEnergyFromFatStore() {
        let L = min(energy.E.underflowFullness!, energy.fullness)
        let maxDeposit = (energy.E.overflowFullness! - L) * energy.E.capacity

        Debug.log(level: 179) {
            "digest.4a1a: backfillEnergyFromFatStore pre:"
                + " fat \(fatStore.level), energy \(energy.level)(\(energy.fullness * 100)%), maxDeposit \(maxDeposit)"
        }

        defer {
            Debug.log(level: 179) {
                "digest.4a1b: backfillEnergyFromFatStore post:"
                    + " fat \(fatStore.level), energy \(energy.level)"
            }
        }

        guard energy.isUnderflowing else { return }

        transferSurplus(fatStore, energy, maxDeposit: maxDeposit)
    }

    func overflowEnergyToFat() {
        Debug.log(level: 179) {
            "digest.4a0a: overflowEnergyToFat pre:"
                + " energy \(energy.level), fat \(fatStore.level)"
        }

        defer {
            Debug.log(level: 179) {
                "digest.4a0a: overflowEnergyToFat post:"
                    + " energy \(energy.level), fat \(fatStore.level)"
            }
        }

        guard energy.isOverflowing else { return }

        let maxDraw = (energy.fullness - energy.E.overflowFullness!) * energy.E.capacity
        transferSurplus(energy, fatStore, maxDraw: maxDraw)
    }

    func overflowFatToSpawn() {
        guard fatStore.isOverflowing else { return }

        Debug.log(level: 179) { "fatStore is overflowing" }

        let L = min(fatStore.E.overflowFullness!, fatStore.fullness)
        let maxDraw = (1 - L) * fatStore.E.capacity

        // Make it expensive to create a new embryo
        guard let spawn = self.sporangium else {
            if fatStore.isFull {
                Debug.log(level: 179) { "Create spawn embryo" }
                self.sporangium = ChamberedStore(.spawn, 2)
                fatStore.withdrawFromSurplus(max: maxDraw)
            }

            return
        }

        // Once the three main chambers are full, we can make a new arkon
        for chamber in [spawn.fatStore!, spawn.hamStore, spawn.oxygenStore] {
            if !fatStore.isOverflowing { break }

            transferSurplus(fatStore, chamber, maxDraw: maxDraw)
        }

        Debug.log(level: 181) {
            "Filling spawn embryo"
            + "; fat \(spawn.fatStore!.fullness * 100)%"
            + "; ham \(spawn.hamStore.fullness * 100)%"
            + "; oxygen \(spawn.oxygenStore.fullness * 100)%"
        }
    }
}

extension Metabolism {
    func processStorage(_ embryoIsPresent: Bool) {
        // Save surplus energy to fat store whenever possible
        let energyToFat = energy.isOverflowing && !fatStore.isFull

        // Backfilling the energy store from the fat store isn't allowed
        // while the arkon is still drawing from its birth embryo
        let fatToEnergy = energy.isUnderflowing && !embryoIsPresent && !fatStore.isEmpty

        // Saving up for a new offspring also isn't allowed for arkons
        // that are still drawing from their birth embryos
        let fatToSpawn =  fatStore.isOverflowing && !embryoIsPresent

        Debug.log(level: 179) {
            "digest.4a"
            + "; energy \(energy.level), transfer \(energyToFat)"
            + "; fat \(fatStore.level), transfer \(fatToEnergy)/\(fatToSpawn)"
        }

        // Overflow to fat store is mutually exclusive from backfilling the
        // energy store
        if energyToFat      { overflowEnergyToFat() }
        else if fatToEnergy { backfillEnergyFromFatStore() }

        // Build up a new spawn embryo whenever the fat store overflows
        if fatToSpawn  { overflowFatToSpawn() }

        Debug.log(level: 179) {
            "digest.4b"
            + "; energy \(energy.level)"
            + "; fat \(fatStore.level)"
        }
    }
}
