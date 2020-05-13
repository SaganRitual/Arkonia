extension Metabolism {
    func digest() {
        Debug.log(level: 179) { "digest.0" }

        for id in secondaryStores {
            guard let source = embryo.selectStore(id) else { fatalError() }
            if source.isEmpty { continue }
            guard let sink = self.selectStore(id) else { fatalError() }

            Debug.log(level: 180) {
                "digest.1a: \(source.E.organID):\(source.E.chamberID) level \(source.level) \(sink.E.organID):\(sink.E.chamberID) level \(sink.level)"
            }

            let (netDraw, netDeposit, drawFullness, depositFullness) =
                getTransferLevels(from: source, to: sink)

            Debug.log(level: 180) {
                "digest.1b: netDraw \(netDraw) netDeposit \(netDeposit) drawFullness \(drawFullness) depositFullness \(depositFullness)"
            }

            // Note: embryo never overflows to fat store
            transfer(netDraw, from: source, as: netDeposit, to: sink)

            Debug.log(level: 180) {
                "digest.1c: source result \(source.level) sink result \(sink.level)"
            }
        }

        // Remember the available capacity so we can check whether the
        // embryo was the only source of input to the energy store, in which
        // case there is no refill of the energy store from the fat store. That
        // can only happen with energy that comes from the stomach. No
        // particular reason for it except the capricious deity (me)
        let preStomachEnergyStoreAvailableCapacity = energy.availableCapacity

        for id in secondaryStores {
            guard let source = stomach.selectStore(id), !source.isEmpty,
                  let sink = self.selectStore(id) else { continue }

            Debug.log(level: 180) {
                "digest.2a: \(source.E.organID):\(source.E.chamberID) level \(source.level) \(sink.E.organID):\(sink.E.chamberID) level \(sink.level)"
            }

            let (netDraw, netDeposit, drawFullness, depositFullness) =
                getTransferLevels(from: source, to: sink)

            Debug.log(level: 180) {
                "digest.2b: netDraw \(netDraw) netDeposit \(netDeposit) drawFullness \(drawFullness) depositFullness \(depositFullness)"
            }

            // Note: transfer doesn't overflow energy store to fat store
            transfer(netDraw, from: source, as: netDeposit, to: sink)

            Debug.log(level: 180) {
                "digest.2c: source result \(source.level) sink result \(sink.level)"
            }

            // Note: unlike embryo ooze in the embryo pass, stomach ooze
            // can oveflow from the energy store to the fat store, and here
            // is where we do it
            let overflowDraw = netDraw * (1 - drawFullness)
            let overflowDeposit = netDeposit * (1 - drawFullness)

            if overflowDraw > 0 {
                transfer(overflowDraw, from: source, as: overflowDeposit, to: sink)

                Debug.log(level: 180) {
                    "digest.2d: source result \(source.level) sink result \(sink.level)"
                }
            }
        }

        Debug.log(level: 180) { "digest.4" }

        // If it's equal, it means we didn't tranfer anything from energy to
        // fat, so it's ok to atempt to backfill from fat back to energy. If they're
        // unequal, it means we put some into the fat store from energy, so it's
        // not ok to attempt to backfill
        let fatToReady = energy.isUnderflowing && !fatStore.isEmpty &&
            energy.availableCapacity == preStomachEnergyStoreAvailableCapacity

        if fatToReady {
            Debug.log(level: 180) { "digest.5" }
            let maxDeposit = preStomachEnergyStoreAvailableCapacity - energy.availableCapacity
            let (netDraw, netDeposit, _, _) =
                getTransferLevels(from: fatStore, to: energy, maxDeposit: maxDeposit)

            if netDraw > 0 && netDeposit > 0 {
                Debug.log(level: 180) { "digest.6" }
                transfer(netDraw, from: fatStore, as: netDeposit, to: energy)
            }
        }

        Debug.log(level: 180) { "digest.7" }
    }
}
