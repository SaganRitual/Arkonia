import Foundation

struct SensorPadMapper {
    let centerAbsoluteIndex: Int
    let onComplete: () -> Void
    let onWakeupFromDefer: ((SensorPadMapper) -> Void)?
    let sensorPad: UnsafeMutablePointer<IngridCellDescriptor>
    let sensorPadCCells: Int

    init(
        _ sensorPadCCells: Int, _ centerAbsoluteIndex: Int,
        _ sensorPad: UnsafeMutablePointer<IngridCellDescriptor>,
        _ onComplete: @escaping () -> Void
    ) {
        self.centerAbsoluteIndex = centerAbsoluteIndex
        self.onComplete = onComplete
        self.sensorPad = sensorPad
        self.sensorPadCCells = sensorPadCCells
        self.onWakeupFromDefer = nil
    }

    init(
        _ saveForDefer: SensorPadMapper,
        _ onWakeupFromDefer: ((SensorPadMapper) -> Void)?
    ) {
        self.centerAbsoluteIndex = saveForDefer.centerAbsoluteIndex
        self.onComplete = saveForDefer.onComplete
        self.sensorPad = saveForDefer.sensorPad
        self.sensorPadCCells = saveForDefer.sensorPadCCells
        self.onWakeupFromDefer = nil
    }
}
