import Foundation

extension Metabolism {
    struct TransferLevels {
        internal init(
            _ netNativeDraw: CGFloat, _ netNativeDeposit: CGFloat,
            _ drawFullness: CGFloat, _ depositFullness: CGFloat
        ) {
            self.netNativeDraw = netNativeDraw
            self.netNativeDeposit = netNativeDeposit
            self.drawFullness = drawFullness
            self.depositFullness = depositFullness
        }

        let netNativeDraw: CGFloat
        let netNativeDeposit: CGFloat
        let drawFullness: CGFloat
        let depositFullness: CGFloat
    }

    func getTransferLevels(
        from source: OozeStorage, to sink: OozeStorage,
        maxDeposit: CGFloat = CGFloat.infinity,
        maxDraw: CGFloat = CGFloat.infinity
    ) -> TransferLevels {
        let sourceLevelNative_ = source.level * source.E.compression
        let sourceLevelNative = min(sourceLevelNative_, maxDraw)
        let sourceLevelKgOoze = sourceLevelNative * source.E.contentDensity

        let sinkAvailableCapacityNative_ = sink.availableCapacity * sink.E.compression
        let sinkAvailableCapacityNative = min(sinkAvailableCapacityNative_, maxDeposit)
        let sinkAvailableCapacityKgOoze = sinkAvailableCapacityNative * sink.E.contentDensity

        let transferrable = min(sourceLevelKgOoze, sinkAvailableCapacityKgOoze)
        let drawFullness = (sourceLevelKgOoze > 0) ? (transferrable / sourceLevelKgOoze) : 0
        let depositFullness = (sinkAvailableCapacityKgOoze > 0) ? (transferrable / sinkAvailableCapacityKgOoze) : 0

        let fromSourceTransfer = transferrable / source.E.contentDensity
        let netNativeDraw = fromSourceTransfer / source.E.compression

        let toSinkTransfer = transferrable / sink.E.contentDensity
        let netNativeDeposit = toSinkTransfer / sink.E.compression

        Debug.log(level: 179) {
            "getTransferLevels: source \(source.E.organID):\(source.E.chamberID)"
            + " level \(source.level) compression \(source.E.compression)"
            + " native \(sourceLevelNative)"
            + " kg \(sourceLevelKgOoze)"
            + " transferrable \(transferrable)"
            + " draw fullness \(drawFullness)"
            + " from source transfer \(fromSourceTransfer)"
            + " net native draw \(netNativeDraw)"
        }

        Debug.log(level: 179 ) {
            "getTransferLevels: sink \(sink.E.organID):\(sink.E.chamberID) capacity: "
            + " native \(sink.E.capacity) - \(sink.level) = \(sinkAvailableCapacityNative)"
            + " kg \(sinkAvailableCapacityKgOoze)"
            + " transferrable \(transferrable)"
            + " deposit fullness \(depositFullness)"
            + " to sink transfer \(toSinkTransfer)"
            + " net native deposit \(netNativeDeposit)"
        }

        return TransferLevels(netNativeDraw, netNativeDeposit, drawFullness, depositFullness)
    }

    @discardableResult
    func transfer(
        _ sourceTransferQuantity: CGFloat, from source: OozeStorage,
        as sinkTransferQuantity: CGFloat, to sink: OozeStorage
    ) -> CGFloat {
        let netDraw = source.withdraw(sourceTransferQuantity)
        let netDeposit = sink.deposit(sinkTransferQuantity)

        Debug.log(level: 179) {
            "transfer(\(sourceTransferQuantity)"
            + ", from: \(source.E.organID)"
            + ", as: \(sinkTransferQuantity)"
            + ", to: \(sink.E.organID)"
            + ")"
            + " -> \(netDraw) -> \(netDeposit)"
        }

        return netDeposit
    }

    func transferSurplus(
        _ source: OozeStorage,
        _ sink: OozeStorage,
        maxDeposit: CGFloat = CGFloat.infinity,
        maxDraw: CGFloat = CGFloat.infinity
    ) {
        let transferLevels = getTransferLevels(
            from: source, to: sink, maxDeposit: maxDeposit, maxDraw: maxDraw
        )

        if transferLevels.netNativeDraw > 0 && transferLevels.netNativeDeposit > 0 {
            transfer(
                transferLevels.netNativeDraw, from: source,
                as: transferLevels.netNativeDeposit, to: sink
            )
        }
    }
}
