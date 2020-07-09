import Foundation

extension Metabolism {
    func digest() {
        Debug.log(level: 202) { "digest.0" }

        // For no particular reason, I've decided to forbid Arkons to draw on
        // their fat reserves from grazing until they've used up their whole
        // embryo
        let embryoIsPresent = processEmbryo()

        processStomach()

        processStorage(embryoIsPresent)

        Debug.log(level: 202) { "digest.7; mass \(mass)" }
    }
}

extension Metabolism {
    func processEmbryo() -> Bool {
        guard let embryo = self.embryo else {
            Debug.log(level: 202) { "digest.00: embryo is no longer attached" }
            return false
        }

        // If it's empty, we'll get rid of the excess mass and maintenance costs
        var detachEmbryo = true

        for id in secondaryStores {
            let source = (embryo.selectStore(id))!

            if source.isEmpty {
                Debug.log(level: 202) { "digest.0a: embryo chamber \(id) is empty" }
                continue
            }

            let sink = (self.selectStore(id))!

            Debug.log(level: 202) {
                "digest.1a:"
                + " \(source.E.organID):\(source.E.chamberID) level \(source.level)"
                + " \(sink.E.organID):\(sink.E.chamberID) level \(sink.level)"
            }

            let transferLevels = getTransferLevels(from: source, to: sink)

            Debug.log(level: 202) {
                "digest.1b: netDraw \(transferLevels.netNativeDraw)"
                + " netDeposit \(transferLevels.netNativeDeposit)"
                + " drawFullness \(transferLevels.drawFullness)"
                + " depositFullness \(transferLevels.depositFullness)"
            }

            // Note: transfer doesn't overflow energy store to fat store when
            // we're drawing from the embryo
            transfer(
                transferLevels.netNativeDraw, from: source,
                as: transferLevels.netNativeDeposit, to: sink
            )

            // There's still something left in the embryo, don't let go of it yet
            if !source.isEmpty { detachEmbryo = false }

            Debug.log(level: 202) {
                "digest.1c: source result \(source.level) sink result \(sink.level)"
            }
        }

        if detachEmbryo { detachBirthEmbryo() }

        return true
    }
}

extension Metabolism {
    func processStomach() {
        for id in secondaryStores {
            guard let source = stomach.selectStore(id) else {
                Debug.log(level: 202) { "digest.2.0a: stomach has no \(id) chamber" }
                continue
            }

            if source.isEmpty {
                Debug.log(level: 202) { "digest.2.0b: stomach chamber \(id) is empty" }
                continue
            }

            guard let sink = self.selectStore(id) else {
                Debug.log(level: 202) {
                    if let so = stomach.selectStore(id) { return "store \(so.E.organID)/\(so.E.chamberID) empty \(so.isEmpty)" }
                    else { return nil }
                }

                continue
            }

            Debug.log(level: 202) {
                "digest.2a: \(source.E.organID):\(source.E.chamberID) level \(source.level) \(sink.E.organID):\(sink.E.chamberID) level \(sink.level)"
            }

            let transferLevels = getTransferLevels(from: source, to: sink)

            Debug.log(level: 202) {
                "digest.2b: netDraw \(transferLevels.netNativeDraw)"
                + " netDeposit \(transferLevels.netNativeDeposit)"
                + " drawFullness \(transferLevels.drawFullness)"
                + " depositFullness \(transferLevels.depositFullness)"
            }

            // Note: transfer from stomach energy store compartment to main
            // metabolism energy store can cause the latter to fill beyond its
            // overflow level. It will always stop when the full capacity is
            // reached
            transfer(
                transferLevels.netNativeDraw, from: source,
                as: transferLevels.netNativeDeposit, to: sink
            )

            Debug.log(level: 202) {
                "digest.2c: source result \(source.level) sink result \(sink.level)"
            }
        }
    }
}
