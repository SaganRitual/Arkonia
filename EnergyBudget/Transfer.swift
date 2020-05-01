// swiftlint:disable large_tuple
import Foundation

extension Metabolism {
    func getTransferLevels(
        from source: OozeStorage, to sink: OozeStorage, maxDeposit: CGFloat = CGFloat.infinity
    ) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let sourceLevelNative = source.level * source.E.compression
        let sourceLevelKgOoze = sourceLevelNative * source.E.contentDensity

        let sinkLevelNative_ = sink.availableCapacity * sink.E.compression
        let sinkLevelNative = min(sinkLevelNative_, maxDeposit)
        let sinkLevelKgOoze = sinkLevelNative * sink.E.contentDensity

        let transferrable = min(sourceLevelKgOoze, sinkLevelKgOoze)
        let drawFullness = (sourceLevelKgOoze > 0) ? (transferrable / sourceLevelKgOoze) : 0
        let depositFullness = (sinkLevelKgOoze > 0) ? (transferrable / sinkLevelKgOoze) : 0

        let fromSourceTransfer = transferrable / source.E.contentDensity
        let netNativeDraw = fromSourceTransfer / source.E.compression

        let toSinkTransfer = transferrable / sink.E.contentDensity
        let netNativeDeposit = toSinkTransfer / sink.E.compression

        Debug.log(level: 179) {
            "getTransferLevels: source \(source.E.organID):\(source.E.chamberID)"
            + " native \(sourceLevelNative)"
            + " kg \(sourceLevelKgOoze)"
            + " transferrable \(transferrable)"
            + " draw fullness \(drawFullness)"
            + " from source transfer \(fromSourceTransfer)"
            + " net native draw \(netNativeDraw)"
        }

        Debug.log(level: 179) {
            "getTransferLevels: sink \(sink.E.organID):\(sink.E.chamberID) capacity: "
            + " native \(sink.E.capacity) - \(sink.level) = \(sinkLevelNative)"
            + " kg \(sinkLevelKgOoze)"
            + " transferrable \(transferrable)"
            + " deposit fullness \(depositFullness)"
            + " to sink transfer \(toSinkTransfer)"
            + " net native deposit \(netNativeDeposit)"
        }

        return (netNativeDraw, netNativeDeposit, drawFullness, depositFullness)
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

    @discardableResult
    func transferSurplus(
        _ maxQuantity_: CGFloat?, from source: OrganProtocol,
        to sink: OrganProtocol
    ) -> CGFloat {
        let maxQuantity = maxQuantity_ ?? sink.storage.availableCapacity
        let net = min(maxQuantity, sink.storage.availableCapacity)

        let netDraw: CGFloat, netDeposit: CGFloat
        if net > 0 {
            netDraw = source.storage.withdraw(net)
            netDeposit = sink.storage.deposit(net)
        } else { netDraw = 0; netDeposit = 0 }

        Debug.log(level: 179) {
            "transferSurplus(\(maxQuantity)"
            + ", from: \(source.storage.E.organID)"
            + ", to: \(sink.storage.E.organID)"
            + " -> \(netDraw) -> \(netDeposit)"
        }

        return net
    }
}
