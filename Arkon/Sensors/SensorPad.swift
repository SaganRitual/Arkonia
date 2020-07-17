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
            let s = theSensors.dropFirst().map { engageSensors_B($0, gridIsLocked: gridIsLocked) }

            Debug.log(level: 215) { "engaging for \(AKName(name)): \(s)" }

            mainDispatch(onComplete)
        }

        func engageSensors_B(_ sensor: CellSensor, gridIsLocked: Bool) -> String {
            let (gridCell, virtualPosition) = Grid.cellAt(
                sensor.sensorPadLocalIndex, from: self.spindle.gridCell
            )

            let t = "\(gridCell.properties)"
                + (gridCell.lock.isLocked ? "T" : "F")
                + (sensor.iHaveTheLiveConnection ? "T" : "F")

            Debug.log(level: 215) {
                "engage sensor localIx \(sensor.sensorPadLocalIndex)"
                + " from center \(gridCell.properties) v:\(virtualPosition)"
            }

            sensor.engage(with: gridCell, virtualPosition: virtualPosition, gridIsLocked: gridIsLocked)

            let u = (gridCell.lock.isLocked ? "T" : "F")
                    + (sensor.iHaveTheLiveConnection ? "T" : "F")

            return t + u
        }
    }
}

extension SensorPad {
    // Do we ever need to blindly release all of them, rather than selectively
    // depending on pre- or post-jump? Not sure
    func disengageFullSensorPad() { theSensors.dropFirst().forEach { _ = $0.disengage() } }

    // "refractorize", as in, "cause to enter a refractory period for recovery"
    //
    // Release all the cells in the sensor pad that won't be involved in the
    // jump. They're dormant now because we've read them and they need to rest.
    // We need only the two remaining "shuttle" cells, meaning the cell we're in,
    // and the cell we're headed for when we jump
    func refractorizeSensors(_ jumpSpec: JumpSpec?) {
        guard let js = jumpSpec else { return }

        let s: [String] = theSensors
            .dropFirst()
            .filter({ $0.sensorPadLocalIndex != js.to.sensorSS.sensorPadLocalIndex })
            .map({
                let c = $0.disengage() ? "L" : "D"
                return "\($0.liveGridCell.properties)\(c)\($0.sensorPadLocalIndex)"
            })

        Debug.log(level: 215) { "refractorizeSensors \(AKName(name)) keep \(js.to.sensorSS.sensorPadLocalIndex)): \(s)" }
    }

    // "refractorize", as in, "cause to enter a refractory period for recovery"
    //
    // Release the shuttle, meaning the cell we started in and the cell we just
    // now jumped to
    func refractorizeShuttle(_ jumpSpec: JumpSpec?) {
        guard let js = jumpSpec else {
            Debug.log(level: 215) { "refractorizeShuttle says jumpSpec is nil -- spawn?" }
            return
        }

        Debug.log(level: 215) { "from.releaselock \(AKName(js.from.contents.arkon?.arkon?.name)) \(js.from.properties)" }
        assert(js.from.lock.isLocked)
        js.from.lock.releaseLock(false)
        let d = js.to.sensorSS.disengage()
        Debug.log(level: 215) { "to.releaselock \(AKName(js.to.cellSS.contents.arkon?.arkon?.name)) \(js.to.cellSS.properties)/\(d)" }
    }
}
