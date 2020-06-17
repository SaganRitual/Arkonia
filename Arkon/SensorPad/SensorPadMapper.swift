import Foundation

struct SensorPadMapper {
    let centerAbsoluteIndex: Int
    let onComplete: () -> Void
    let onWakeupFromDefer: ((SensorPadMapper) -> Void)?
    let sensorPadThePad: UnsafeMutablePointer<IngridCellConnector?>
    let sensorPadCCells: Int

    init(
        _ sensorPadCCells: Int, _ centerAbsoluteIndex: Int,
        _ sensorPadThePad: UnsafeMutablePointer<IngridCellConnector?>,
        _ onComplete: @escaping () -> Void
    ) {
        self.centerAbsoluteIndex = centerAbsoluteIndex
        self.onComplete = onComplete
        self.sensorPadThePad = .init(sensorPadThePad)
        self.sensorPadCCells = sensorPadCCells
        self.onWakeupFromDefer = nil
    }

    init(
        _ saveForDefer: SensorPadMapper,
        _ onWakeupFromDefer: ((SensorPadMapper) -> Void)?
    ) {
        self.centerAbsoluteIndex = saveForDefer.centerAbsoluteIndex
        self.onComplete = saveForDefer.onComplete
        self.sensorPadThePad = .init(saveForDefer.sensorPadThePad)
        self.sensorPadCCells = saveForDefer.sensorPadCCells
        self.onWakeupFromDefer = nil
    }
}
