import Dispatch

extension Stepper {
    func disengageGrid() {
        Debug.log(level: 213) { "stepper.disengageGrid \(self.name)" }

        if let js = jumpSpec {
            Debug.log(level: 215) { "disengageGrid.refractorizeShuttle \(AKName(name)) \(spindle.gridCell.properties)" }
            self.spindle.sensorPad.refractorizeShuttle(js)
        } else {
            Debug.log(level: 215) { "disengageGrid.full+spindle \(AKName(name)) \(spindle.gridCell.properties)" }
            self.spindle.sensorPad.disengageFullSensorPad()
            self.spindle.gridCell.lock.releaseLock(true)
        }

        jumpSpec = nil
        engageGrid()
    }

    func engageGrid() { mainDispatch(engageGrid_B) }
}

private extension Stepper {
    func engageGrid_B() {
        Debug.log(level: 213) { "stepper.engageGrid \(self.name)" }
        Debug.debugColor(self, .red, .yellow)

        spindle.getLifecycleLock(engageGrid_C)
    }

    func engageGrid_C() {
        if self.isDyingFromParasite { apoptosize(); return }
        sensorPad.engageSensors(tickLife)
    }
}
