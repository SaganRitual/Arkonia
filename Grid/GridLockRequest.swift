import Foundation

struct GridLockRequest {
    let centerAbsoluteIndex: Int
    let onCellReady: () -> Void
    let unsafeCellConnectors: UnsafeCellConnectors
    let cUnsafeCellConnectors: Int

    init(
        _ sensorPad: SensorPad, _ onCellReady: @escaping () -> Void
    ) {
        self.centerAbsoluteIndex = sensorPad.centerAbsoluteIndex
        self.onCellReady = onCellReady
        self.unsafeCellConnectors = .init(mutating: sensorPad.unsafeCellConnectors)
        self.cUnsafeCellConnectors = sensorPad.cCells
    }
}
