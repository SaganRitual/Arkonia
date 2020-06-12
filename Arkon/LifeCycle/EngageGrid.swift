import Dispatch

extension Stepper {
    func engageGrid() {
        MainDispatchQueue.async {
            Debug.log(level: 206) { "engageGrid" }
            Debug.debugColor(self, .red, .yellow)
            self.sensorPad.engageSensorPad(for: self, self.tickLife)
        }
    }
}
