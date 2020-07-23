import Foundation

class SensorPad {
    var energyLevel: Float = 0
    let name: ArkonName
    let spindle: Spindle
    var theSensors = [CellSensor]()

    init(name: ArkonName, _ spindle: Spindle, _ cCells: Int) {
        self.name = name
        self.spindle = spindle

        self.theSensors.reserveCapacity(cCells)

        (0..<cCells).forEach { self.theSensors.append(.init($0)) }
    }
}

extension SensorPad {
    func copyNutritionInfo() {
        energyLevel = Float(spindle.arkon.metabolism.energy.level)
    }

    func engageSensors(_ onComplete: @escaping () -> Void) {

        GridLock.lockQueue.async { engageSensors_A(gridIsLocked: true) }

        func engageSensors_A(gridIsLocked: Bool) {
            theSensors.dropFirst().forEach { engageSensors_B($0, gridIsLocked: gridIsLocked) }
            mainDispatch(onComplete)
        }

        func engageSensors_B(_ sensor: CellSensor, gridIsLocked: Bool) {
            let (gridCell, virtualPosition) = Grid.cellAt(
                sensor.sensorPadLocalIndex, from: self.spindle.gridCell
            )

            sensor.engage(with: gridCell, virtualPosition: virtualPosition, gridIsLocked: gridIsLocked)
        }
    }
}

extension SensorPad {
    // Do we ever need to blindly release all of them, rather than selectively
    // depending on pre- or post-jump? Not sure
    func disengageFullSensorPad() { theSensors.dropFirst().forEach { $0.disengage() } }

    // "refractorize", as in, "cause to enter a refractory period for recovery"
    //
    // Release all the cells in the sensor pad that won't be involved in the
    // jump. They're dormant now because we've read them and they need to rest.
    // We need only the two remaining "shuttle" cells, meaning the cell we're in,
    // and the cell we're headed for when we jump
    func refractorizeSensors(_ jumpSpec: JumpSpec?) {
        guard let js = jumpSpec else { return }

        theSensors
            .dropFirst()
            .filter({ $0.sensorPadLocalIndex != js.to.sensorSS.sensorPadLocalIndex })
            .forEach({ $0.disengage() })
    }

    // "refractorize", as in, "cause to enter a refractory period for recovery"
    //
    // Release the shuttle, meaning the cell we started in and the cell we just
    // now jumped to
    func refractorizeShuttle(_ jumpSpec: JumpSpec?) {
        guard let js = jumpSpec else { return }

        js.from.lock.releaseLock(false)
        js.to.sensorSS.disengage()
    }
}
