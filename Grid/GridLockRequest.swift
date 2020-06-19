import Foundation

struct GridLockRequest {
    let centerAbsoluteIndex: Int
    let onCellReady: () -> Void
    let unsafeCellConnectors: UnsafeCellConnectors
    let cUnsafeCellConnectors: Int

    init(
        _ sensorPad: SensorPad, _ cellLocalIndex: Int,
        _ onCellReady: @escaping () -> Void
    ) {
        self.centerAbsoluteIndex = sensorPad.localIndexToAbsolute(cellLocalIndex)
        self.onCellReady = onCellReady
        self.unsafeCellConnectors = .init(mutating: unsafeCellConnectors)
        self.cUnsafeCellConnectors = sensorPad.cCells
    }
}
